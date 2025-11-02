// import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:game/models/matchroom_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class MatchmakingViewmodel extends ChangeNotifier{
  late IO.Socket _socket;
  bool _searching=false;
  MatchRoom? _matchData;

  bool get searching =>_searching;
  MatchRoom? get matchData => _matchData;

  void connect(String username,String preferredMode,String rank){
      _socket=IO.io("http://${dotenv.env['PUBLIC_IP']}:5001",IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build()
    );
    _socket.connect();
    _socket.onConnect((_){
      print("Conneced to matchmaking server");
      joinQueue(username,preferredMode,rank);
    });
    _socket.on("match_found", (data) {
      print(data);
      _matchData = MatchRoom.fromJson(data);
      print(_matchData);
      _searching = false;
      notifyListeners();
    });
    _socket!.onDisconnect((_) {
      print("🔌 Disconnected from matchmaking server");
    });

  }

  void joinQueue(String username,String preferredMode,String rank){
    _searching=true;
    _socket.emit("join_queue",{
      "username":username,
      "preferredMode":preferredMode,
      "rank":rank
    });
    notifyListeners();
  }
  void leaveQueueAndDisconnect() {
    if (_socket.connected) {
      _socket.emit("leave_queue");
      _socket.disconnect();
      print("🚪 Left queue & disconnected");
    }
    _searching = false;
    _matchData = null;
    notifyListeners();
  }
  void disconnect(){
    _socket.disconnect();
  }


}