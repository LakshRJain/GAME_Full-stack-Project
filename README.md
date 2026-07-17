# Real-Time Game Matchmaking System

Welcome to the **Real-Time Game Matchmaking System**. This repository contains a full-stack implementation of a game matchmaking platform. It pairs players in real-time based on their ranking, enables in-room live chatting, and synchronize player readiness before the game starts. 

The project is split into a **Node.js/Express/Socket.IO backend** containerized with Docker, and a **Flutter cross-platform client app** managed with Provider state management.

---

## 🏗️ Architecture & System Design

The system relies on a hybrid REST and WebSockets architecture to deliver fast, real-time matchmaking combined with persistent user profile and session management:

```mermaid
graph TD
    %% Nodes
    A[Flutter App] -->|HTTPS REST| B(Express REST API - Port 5000)
    A -->|WebSockets| C(Socket.IO Server - Port 5001)
    
    B -->|User Data / JWT Verification| D[(PostgreSQL)]
    C -->|Active Match Rooms| D
    
    C -->|Matchmaking Queues| E[(Redis Cache)]
```

### 1. Matchmaking Flow
1. **Queue Placement**: The player joins the queue via a socket connection (`join_queue` event), passing their username, preferred game mode, and rank.
2. **Rank Queues (Redis)**: The player is pushed into a Redis queue corresponding to their rank: `matchmaking_queue_<Rank>`. The supported ranks are: `Iron`, `Bronze`, `Silver`, and `Gold`.
3. **Match Search (`findMatch`)**:
   - **Exact Match**: The server checks if the player's own rank queue has at least 2 players. If so, they are matched.
   - **Cross-Rank Fallback**: If no exact match is found, the matchmaking algorithm checks adjacent ranks (one level higher or one level lower). If an opponent is found in an adjacent queue, they are matched.
4. **Room Database Insertion**: Upon finding a match, the backend generates a unique UUID `room_id` and records a new matchmaking room entry in the PostgreSQL `match_rooms` table.
5. **Client Notification**: The server emits a `match_found` event containing room details. Both clients join the Socket.IO room (`roomId`) to start chatting and toggling readiness.

---

## 🛠️ Technology Stack

### Backend
- **Core Runtime**: [Node.js (v22)](file:///d:/Projects/Full%20Stack%20Project/Game%20-%20Full%20Stack%20Project/game-matchmaking-backend/package.json)
- **REST Framework**: Express.js (v5)
- **Real-Time Engine**: Socket.IO (v4)
- **Database**: PostgreSQL (v16) for persistent data storage (Users, Match Rooms)
- **Caching & Queues**: Redis (v7) for handling real-time matchmaking queues
- **Auth**: JWT (JSON Web Tokens) with Access/Refresh token rotation, password hashing via `bcrypt`
- **Environment**: Docker & Docker Compose

### Frontend (Flutter Client)
- **UI & Core SDK**: Flutter (v3.35.6)
- **State Management**: Provider (ChangeNotifier pattern)
- **HTTP Client**: Dio (v5) with secure JSON token interceptions
- **Secure Cache**: Flutter Secure Storage (encrypted storage of access/refresh JWTs)
- **Real-Time Client**: Socket.IO Client Dart

---

## 📂 Project Directory Structure

```text
├── .github/workflows/
│   └── ci-cd.yml                     # GitHub Actions CI/CD Pipeline
├── game-matchmaking-backend/         # Node.js backend
│   ├── controllers/
│   │   ├── authController.js         # JWT Registration, Login, Refresh, Logout
│   │   ├── matchmaking.js            # Matchmaking queue (Redis) and room generation
│   │   └── userController.js         # Profile management, stats fetching
│   ├── middleware/
│   │   └── authMiddleware.js         # Express JWT verification middleware
│   ├── routes/
│   │   ├── auth.js                   # Authentication endpoints mapping
│   │   └── user.js                   # User and Profile endpoints mapping
│   ├── db.js                         # PostgreSQL pool client configuration
│   ├── redis_client.js               # Redis client connection configuration
│   ├── index.js                      # Main entrypoint, HTTP + Socket.IO servers
│   ├── Dockerfile                    # Containerization script for backend
│   └── docker-compose.yml            # Multi-container setup (Node, Postgres, Redis)
├── game_matchmaking_frontend/game/   # Flutter Application
│   ├── lib/
│   │   ├── models/
│   │   │   ├── user_model.dart       # Local user profile configuration
│   │   │   └── matchroom_model.dart  # Active matchmaking room model
│   │   ├── services/
│   │   │   ├── auth_service.dart     # HTTP client for Registration & Login
│   │   │   └── profile_repository.dart# HTTP client for Profile edits & data fetching
│   │   ├── viewmodels/
│   │   │   ├── auth_viewmodel.dart   # Authenticated session state provider
│   │   │   ├── profile_viewmodel.dart# Profile update state provider
│   │   │   └── matchmaking_viewmodel.dart# Socket.IO connection and match state provider
│   │   ├── views/
│   │   │   ├── Profile/              # Profile page & related components
│   │   │   ├── login_screen.dart     # Login Page
│   │   │   ├── signup_screen.dart    # Registration Page
│   │   │   └── matchmaking_screen.dart# Searching, lobby chat, & ready up page
│   │   └── main.dart                 # Flutter application initialization
│   └── .env                          # App environmental variables (Public IP)
└── request.http                      # HTTP testing environment calls
```

---

## 🗄️ Database Schemas (PostgreSQL)

The SQL schemas consist of the following structure in PostgreSQL:

### `users` Table
Stores user profile information, authentication credentials, and match stats.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | `PRIMARY KEY` | Unique player ID |
| `username` | `VARCHAR(50)` | `NOT NULL` | Chosen in-game display name |
| `email` | `VARCHAR(100)` | `UNIQUE, NOT NULL` | Login identifier |
| `password` | `VARCHAR(255)` | `NOT NULL` | Hashed password |
| `rank` | `VARCHAR(20)` | Default `'Iron'` | `Iron`, `Bronze`, `Silver`, `Gold` |
| `games_played`| `INT` | Default `0` | Total match count |
| `wins` | `INT` | Default `0` | Total game wins |
| `preferred_game_mode` | `VARCHAR(20)`| - | `solo`, `duo`, or `squad` |
| `country` | `VARCHAR(50)` | - | Country of player |
| `avatar_url` | `TEXT` | - | URL link to user profile image |
| `refresh_token` | `TEXT` | - | Current active JWT refresh token |
| `created_at` | `TIMESTAMP` | Default `NOW()` | Registration timestamp |

### `match_rooms` Table
Maintains logs of active and completed match lobbies created by the matchmaking engine.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `room_id` | `UUID` | `PRIMARY KEY` | Unique room identifier |
| `player1_id` | `VARCHAR(100)` | `NOT NULL` | Socket ID/Database ID of Player 1 |
| `player2_id` | `VARCHAR(100)` | `NOT NULL` | Socket ID/Database ID of Player 2 |
| `player1_username`| `VARCHAR(50)` | `NOT NULL` | Username of Player 1 |
| `player2_username`| `VARCHAR(50)` | `NOT NULL` | Username of Player 2 |
| `rank` | `VARCHAR(20)` | `NOT NULL` | Rank matching group |
| `status` | `VARCHAR(20)` | Default `'waiting'` | Match state (e.g. `waiting`, `active`, `finished`) |
| `created_at` | `TIMESTAMP` | Default `NOW()` | Room initialization timestamp |

---

## 🚀 Local Installation & Configuration

### Prerequisites
- Install **Docker** & **Docker Compose**
- Install **Flutter SDK (v3.35.6 or later)**

---

### 1. Setting Up the Backend

1. Navigate to the backend directory:
   ```bash
   cd game-matchmaking-backend
   ```

2. Create a `.env` file from the configuration template:
   ```env
   DATABASE_URL=postgresql://postgres:admin123@postgres:5432/game_db
   REDIS_URL=redis://redis:6379
   JWT_SECRET=supersecretkey
   JWT_REFRESH_SECRET=anothersecretkey
   PORT=5000
   SERVER_PORT=5001
   ```

3. Spin up the containers using Docker Compose:
   ```bash
   docker-compose up -d --build
   ```
   This command starts:
   - **PostgreSQL** (`postgres_db`) exposing port `5432`
   - **Redis** (`redis_server`) exposing port `6379`
   - **Express + Socket.IO App** (`game_backend`) exposing REST port `5000` and socket port `5001`.

---

### 2. Setting Up the Flutter Frontend

1. Navigate to the game app directory:
   ```bash
   cd game_matchmaking_frontend/game
   ```

2. Create a `.env` file:
   ```env
   PUBLIC_IP=127.0.0.1
   ```
   *(Note: Set `PUBLIC_IP` to your computer's local network IP address if running on a physical Android/iOS test device).*

3. Fetch packages:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

---

## 🌐 API & Socket Documentation

### 1. REST Endpoints (Port `5000`)
For detailed endpoint usage, inspect the [request.http](file:///d:/Projects/Full%20Stack%20Project/Game%20-%20Full%20Stack%20Project/request.http) file.

- **Authentication Route** (`/api/auth`):
  - `POST /register` - Registers a new player.
  - `POST /login` - Log in a player and receive Access & Refresh JWTs.
  - `POST /refresh` - Cycle and reissue fresh Access Tokens.
  - `POST /logout` *(Authorized)* - Clear the user's active session.
- **User Route** (`/api/user`):
  - `GET /profile` *(Authorized)* - Retrieves current user's profile and stats.
  - `PUT /profile` *(Authorized)* - Updates profile settings (username, avatar, country).
  - `PUT /changePassword` *(Authorized)* - Changes password.
  - `GET /all` *(Authorized)* - Lists registered user accounts.

### 2. Socket.IO Gateway (Port `5001`)
Used by [MatchmakingViewmodel](file:///d:/Projects/Full%20Stack%20Project/Game%20-%20Full%20Stack%20Project/game_matchmaking_frontend/game/lib/viewmodels/matchmaking_viewmodel.dart) to manage real-time updates.

- **Client Emits**:
  - `join_queue` (data: `{ username, preferredMode, rank }`) - Enters the queue.
  - `leave_queue` - Exits search.
  - `join_room` (data: `{ roomId, username }`) - Enters the assigned match room after a pairing.
  - `send_message` (data: `{ roomId, sender, message }`) - Sends chat messages.
  - `player_ready` (data: `{ roomId, username }`) - Toggles the ready state in the matchmaking room.
- **Server Broadcasts**:
  - `match_found` (payload: `MatchRoom` JSON) - Dispatched when matching criteria are fulfilled.
  - `player_joined` (payload: `{ username }`) - Notifies the host room when the opponent arrives.
  - `receive_message` (payload: `{ sender, message }`) - Broadcasts user chat messages.
  - `ready_update` (payload: `{ username, ready: true }`) - Synces player readiness states.

---

## 🚀 CI/CD Pipeline

The project features a fully configured GitHub Actions workflow configured in [.github/workflows/ci-cd.yml](file:///d:/Projects/Full%20Stack%20Project/Game%20-%20Full%20Stack%20Project/.github/workflows/ci-cd.yml).

1. **Backend Integration (Node.js CI)**:
   - Installs dependencies on `ubuntu-latest`.
   - Runs code formatting check and project lint check (`npm run lint`).
   - Executes tests (`npm test`).
2. **Frontend Integration (Flutter CI)**:
   - Sets up the Flutter environment with version `3.35.6`.
   - Installs packages via `flutter pub get`.
   - Generates `.env` using secret environment configurations.
   - Compiles and builds a release-ready Android APK (`flutter build apk`).
3. **EC2 Continuous Deployment**:
   - Executes only when the branch pushed is `main`.
   - Authenticates over SSH onto the host AWS EC2 instance.
   - Pulls recent changes, updates environment variables, and deploys the containers via Docker Compose (`docker-compose up -d --build`).
