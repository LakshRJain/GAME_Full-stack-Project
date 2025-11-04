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
    if (vm.searching) {
      vm.leaveQueueAndDisconnect();
      print("Hiii");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    vm = Provider.of<MatchmakingViewmodel>(context);
    final profileVM = Provider.of<ProfileViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Match Making')),
      body: Center(
        child: vm.searching
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Searching for match...'),
                  TextButton(
                    onPressed: () {
                      vm.leaveQueueAndDisconnect();
                    },
                    child: const Text('Cancel Search'),
                  ),
                ],
              )
            : vm.matchData != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🏠 Room: ${vm.matchData!.roomId}'),
                  Text(
                    "${vm.matchData!.player1Username} vs ${vm.matchData!.player2Username}",
                  ),
                  const SizedBox(height: 20),

                  // 🟢 Ready Status
                  Column(
                    children: vm.playersReadyStatus.entries.map((entry) => Text('${entry.key}: ${entry.value ? "Ready" : "Not Ready"}')).toList(),
                  ),
                  const Divider(),

                  // 💬 Chat messages
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: vm.messages.length,
                      itemBuilder: (context, index) {
                        final msg = vm.messages[index];
                        return ListTile(
                          title: Text("${msg['sender']}: ${msg['message']}"),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 📩 Send message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onSubmitted: (value) {
                              final user = profileVM.user!;
                              vm.sendMessage(user.username, value);
                            },
                            decoration: const InputDecoration(
                              hintText: "Type message...",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🟢 Ready button
                  ElevatedButton(
                    onPressed: () {
                      final user = profileVM.user!;
                      vm.markReady(user.username);
                    },
                    child: const Text("I’m Ready!"),
                  ),

                  const SizedBox(height: 10),

                  // 🚪 Leave Room
                  ElevatedButton(
                    onPressed: () {
                      vm.leaveQueueAndDisconnect();
                    },
                    child: const Text('Leave Room'),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: () {
                  final _user = profileVM.user;
                  vm.connect(
                    _user!.username,
                    _user.preferredGameMode!,
                    _user.rank!,
                  );
                },
                child: const Text("Find Match"),
              ),
      ),
    );
  }
}
