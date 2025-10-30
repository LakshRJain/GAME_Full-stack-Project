import 'package:flutter/material.dart';
import 'package:game/models/user_model.dart';
import 'stat_item.dart';

class StatsGrid extends StatelessWidget {
  final UserModel user;
  const StatsGrid({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatItem(label: 'Rank', value: user.rank.toString(), icon: Icons.military_tech_outlined),
            _buildDivider(),
            StatItem(label: 'Matches', value: user.gamesPlayed.toString(), icon: Icons.games_outlined),
            _buildDivider(),
            StatItem(label: 'Wins', value: user.wins.toString(), icon: Icons.emoji_events_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey[200]);
  }
}
