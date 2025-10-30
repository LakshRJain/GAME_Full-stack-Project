import 'package:flutter/material.dart';
import 'package:game/viewmodels/auth_viewmodel.dart';
import 'package:game/views/login_screen.dart';
import 'package:game/views/profile_screen.dart';
import 'package:game/views/signup_screen.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>AuthViewModel())
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Matchmaking App',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/profile':(context)=>const ProfileScreen()
      },

      home: Consumer<AuthViewModel>(
        builder: (context,authVM,_){
          if(authVM.user!=null){
            return Scaffold();
          }else{
            return const LoginScreen();
          }
        }
      )
    );
  }
}

