import 'package:flutter/material.dart';
import 'package:game/models/user_model.dart';
import 'package:game/viewmodels/auth_viewmodel.dart';
import 'package:game/viewmodels/matchmaking_viewmodel.dart';
import 'package:game/views/matchmaking_screen.dart';
import 'package:provider/provider.dart';
import 'package:game/viewmodels/profile_viewmodel.dart';
import 'package:game/views/Profile/widgets/avatar_section.dart';
import 'package:game/views/Profile/widgets/stats_grid.dart';
import 'package:game/views/Profile/widgets/profile_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController countryController;

  @override
  void initState() {
    super.initState();
    
    nameController = TextEditingController();
    countryController = TextEditingController();
    Future.microtask(() {
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      profileVM.fetchProfile();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    final MatchVM = Provider.of<MatchmakingViewmodel>(context);
    final authVm=Provider.of<AuthViewModel>(context);
    if (profileVM.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = profileVM.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user data available')),
      );
    }

    if (nameController.text.isEmpty) {
      nameController.text = user.username;
      countryController.text = user.country ?? '';
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.pushNamed(context, '/matchmaking');
      },child: Text('Match'),),
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(onPressed: (){
            authVm.clearUser();
            Navigator.popAndPushNamed(context, '/login');
          }, icon: authVm.isLoading?SingleChildScrollView():Icon(Icons.logout))  
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarSection(user: user),
              const SizedBox(height: 32),
              StatsGrid(user: user),
              const SizedBox(height: 32),
              ProfileForm(
                nameController: nameController,
                countryController: countryController,
                onUpdate: () {
                  final updatedUser = UserModel(
                      username: nameController.text,
                      email: user.email,
                      country: countryController.text,
                    );
                  profileVM.updateProfile(updatedUser);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
