import 'package:flutter/material.dart';
import 'package:game/models/user_model.dart';
import 'package:game/services/profile_repository.dart';
import 'package:game/viewmodels/matchmaking_viewmodel.dart';
import 'package:game/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  late MatchmakingViewmodel vm;
  @override
  void dispose() {
    if(vm.searching){
      vm.leaveQueueAndDisconnect();
      print("Hiii");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    vm=Provider.of<MatchmakingViewmodel>(context);
    final profileVM=Provider.of<ProfileViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Match Making'),),
      body: Center(
        child: vm.searching?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            const Text('Searching for match...'),
            TextButton(onPressed: (){
              vm.leaveQueueAndDisconnect();
            }, child: const Text('Cancel Search'))
          ]
        ):
        vm.matchData!=null?Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Match Found'),
            Text("${vm.matchData!.player1Username} : ${vm.matchData!.player2Username}"),
            ElevatedButton(onPressed: (){
              vm.leaveQueueAndDisconnect();
            }, 
            child: const Text('Find Again'))
          ],
        ):
        ElevatedButton(onPressed: (){
          final _user=profileVM.user;
          vm.connect(_user!.username, _user.preferredGameMode!,_user.rank!);
        }, child: const Text("Find Match"))
      ),
    );
  }
}