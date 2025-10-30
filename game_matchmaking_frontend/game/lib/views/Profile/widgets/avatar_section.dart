import 'package:flutter/material.dart';
import 'package:game/models/user_model.dart';

class AvatarSection extends StatelessWidget {
  final UserModel user;
  const AvatarSection({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue[400],
            backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                ? NetworkImage(user.avatarUrl!)
                : null,
            onBackgroundImageError: (_, __) {},
            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                ? Text(
                    user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
