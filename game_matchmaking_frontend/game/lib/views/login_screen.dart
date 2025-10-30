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


    return Container(
      decoration: BoxDecoration(
          gradient:  LinearGradient(colors: [Colors.white,Colors.blue],begin: Alignment.topCenter,end: Alignment.bottomCenter)
        ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
          title: const Text('Login'),
        ),
        body:Padding(
          padding: const EdgeInsets.all(30),
          child:Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(150, 50),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      
                      borderRadius: BorderRadius.circular(40),
                      side: BorderSide(color: Colors.black,width: 1.5)
                    )
                  ),
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
                }, 
                child: Text('SignUp'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black
                ),
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}