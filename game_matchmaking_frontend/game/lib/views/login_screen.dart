import 'package:flutter/material.dart';
import 'package:game/viewmodels/auth_viewmodel.dart';
import 'package:game/views/profile_screen.dart';
import 'package:game/views/signup_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body:Padding(
        padding: const EdgeInsets.all(20),
        child:Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (val)=>val!.isEmpty?'Please enter your mail':null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(
                  labelText: 'Password'
                ),
                validator: (val)=>val!.isEmpty?'Please enter your password':null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: authVM.isLoading?null:()async{
                  if(_formKey.currentState!.validate()){
                    await authVM.login(_emailCtrl.text, _passCtrl.text);
                    if(authVM.user!=null &&mounted){
                      Navigator.popAndPushNamed(context, '/profile');
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login failed'))
                      );
                    }
                  }
                },
                child: authVM.isLoading?
                const CircularProgressIndicator():
                const Text('Login')
              ),
              const SizedBox(height: 20,),
              TextButton(onPressed: (){
                Navigator.popAndPushNamed(context, '/signup');
              }, child: Text('SignUp'))
            ],
          ),
        )
      ),
    );
  }
}