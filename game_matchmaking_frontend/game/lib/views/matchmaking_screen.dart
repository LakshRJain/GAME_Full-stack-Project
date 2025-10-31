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
  Widget build(BuildContext context) {
    vm=Provider.of<MatchmakingViewmodel>(context);
    final profileVM=Provider.of<ProfileViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Match Making'),),
      body: Center(
        child: vm.searching?
        const Text('Searching for match...'):
        vm.matchData!=null?Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Match Found'),
            Text("Opponent: ${vm.matchData!['players'][1]['username']}"),
            ElevatedButton(onPressed: (){
              vm.leaveQueueAndDisconnect();
            }, 
            child: const Text('Find Again'))
          ],
        ):
        ElevatedButton(onPressed: (){
          final _user=profileVM.user;
          vm.connect(_user!.username, _user.preferredGameMode!);
        }, child: const Text("Find Match"))
      ),
    );
  }
}