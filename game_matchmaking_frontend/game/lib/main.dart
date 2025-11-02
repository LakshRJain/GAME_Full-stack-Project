import 'package:flutter/material.dart';
import 'package:game/viewmodels/auth_viewmodel.dart';
import 'package:game/viewmodels/matchmaking_viewmodel.dart';
import 'package:game/viewmodels/profile_viewmodel.dart';
import 'package:game/views/Profile/profile_screen.dart';
import 'package:game/views/login_screen.dart';
import 'package:game/views/signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
Future main() async { 
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>AuthViewModel()),
        ChangeNotifierProvider(create: (_)=>ProfileViewModel()),
        ChangeNotifierProvider(create: (_)=>MatchmakingViewmodel())
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
        '/profile':(context)=> ProfileScreen()
      },

      home: Consumer<AuthViewModel>(
        builder: (context,authVM,_){
          if(authVM.user!=null){
            return ProfileScreen();
          }else{
            return const LoginScreen();
          }
        }
      )
    );
  }
}

