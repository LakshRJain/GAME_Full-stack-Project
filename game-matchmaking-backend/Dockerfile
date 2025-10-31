# Use Node.js LTS image
FROM node:22

# Set working directory inside container
WORKDIR /app

# Copy package files first for caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy rest of the project
COPY . .

# Expose backend ports
EXPOSE 5000
EXPOSE 5001

# Run server
CMD ["npm", "start"]
