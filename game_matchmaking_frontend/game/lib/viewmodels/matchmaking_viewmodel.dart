// import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class MatchmakingViewmodel extends ChangeNotifier{
  late IO.Socket _socket;
  bool _searching=false;
  Map<String,dynamic>? _matchData;

  bool get searching =>_searching;
  Map<String,dynamic>? get matchData => _matchData;

  void connect(String username,String preferredMode){
      _socket=IO.io("http://65.1.110.6:5001",IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build()
    );
    _socket.connect();
    _socket.onConnect((_){
      print("Conneced to matchmaking server");
      joinQueue(username,preferredMode);
    });
    _socket.on("match_found", (data) {
      _matchData = data;
      _searching = false;
      notifyListeners();
    });
    _socket!.onDisconnect((_) {
      print("🔌 Disconnected from matchmaking server");
    });

  }

  void joinQueue(String username,String preferredMode){
    _searching=true;
    _socket.emit("join_queue",{
      "username":username,
      "preferredMode":preferredMode
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