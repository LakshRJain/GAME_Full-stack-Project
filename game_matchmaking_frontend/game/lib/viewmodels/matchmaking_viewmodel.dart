  // import 'package:socket_io_client/socket_io_client.dart' as IO;
  

  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'package:game/models/matchroom_model.dart';
  import 'package:socket_io_client/socket_io_client.dart' as IO;
  import 'package:flutter/material.dart';

  class MatchmakingViewmodel extends ChangeNotifier {
    IO.Socket? _socket;
    bool _searching = false;
    MatchRoom? _matchData;
    List<Map<String,String>> _messages=[];
    Map<String, bool> _playersReadyStatus = {};

    List<Map<String,String>> get messages =>_messages;
     Map<String, bool> get playersReadyStatus => _playersReadyStatus;
    bool get searching => _searching;
    MatchRoom? get matchData => _matchData;

    void connect(String username, String preferredMode, String rank) {
      if (_socket != null) {
        _socket!.clearListeners();
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }
      _socket = IO.io(
        "http://${dotenv.env['PUBLIC_IP']}:5001",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNewConnection()
            .build(),
      );
      _socket!.connect();
      _socket!.onConnect((_) {
        print("Connected to matchmaking server");
        joinQueue(username, preferredMode, rank);
      });

      _socket!.on("match_found", (data) {
        _socket!.emit('join_room', {
          'roomId': data['room_id'],
          'username': username,
        });
        _matchData = MatchRoom.fromJson(data);
        _searching = false;
        _messages.clear();
        _playersReadyStatus = {
          _matchData!.player1Username: false,
          _matchData!.player2Username: false,
        };
        notifyListeners();
      });

      _socket!.on("player_joined", (data) {
        print("👥 Player joined room: ${data['username']}");
      });

      _socket!.on("receive_message", (data) {
        print("💬 ${data['sender']}: ${data['message']}");
        _messages.add(
          {
            "sender":data['sender'],
            "message":data['message'],
          }
        );
        notifyListeners();
      });

      _socket!.on("ready_update", (data) {
        String username = data['username'];
        bool isReady = data['ready'];
        _playersReadyStatus[username] = isReady;
        notifyListeners();
      });

      _socket!.onDisconnect((_) {
        print("🔌 Disconnected from matchmaking server");
      });
    }

    void joinQueue(String username, String preferredMode, String rank) {
      _searching = true;
      _socket?.emit("join_queue", {
        "username": username,
        "preferredMode": preferredMode,
        "rank": rank,
      });
      notifyListeners();
    }

    void leaveQueueAndDisconnect() {
      if (_socket != null && _socket!.connected) {
        _socket!.emit("leave_queue");
        _socket!.disconnect();
        print("🚪 Left queue & disconnected");
      }
      _searching = false;
      _matchData = null;
      _playersReadyStatus={};
      _messages.clear();
      notifyListeners();
    }

    void sendMessage(String sender, String message) {
      if (_matchData == null) return;
      _messages.add({"sender": sender, "message": message});
      notifyListeners();

      _socket?.emit("send_message", {
        "roomId": _matchData!.roomId,
        "sender": sender,
        "message": message,
      });
    }


    void markReady(String username){
      if(_matchData==null)return ;
      _socket?.emit("player_ready" , {
        "roomId":_matchData!.roomId,
        "username":username
      });
    }

    void disconnect() {
      _socket?.disconnect();
    }
  }
