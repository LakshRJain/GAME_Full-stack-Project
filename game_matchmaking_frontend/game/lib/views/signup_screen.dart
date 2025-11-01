import 'package:flutter/material.dart';
import 'package:game/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  // bool _isLoading=false;

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white,Colors.blue],begin:Alignment.topCenter , end: Alignment.bottomCenter)
      
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Sign Up'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'username'
                    ),
                    validator: (val)=>val!.isEmpty?'Please enter username':null,
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'email'
                    ),
                    validator: (val)=>val!.isEmpty?'Please enter email':null,
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: const InputDecoration(
                      labelText: 'password'
                    ),
                    validator: (val)=>val!.isEmpty?'Please enter password':null,
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: const InputDecoration(
                      labelText: 'country'
                    ),
                    validator: (val)=>val!.isEmpty?'Please enter country':null,
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                      fixedSize: Size(150, 50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                        side: BorderSide(color: Colors.black)
                      )
                    ),
                    onPressed: authVM.isLoading?
                    null:
                    () async{
                      if(_formKey.currentState!.validate()){
                        await authVM.register(_usernameCtrl.text, _emailCtrl.text, _passCtrl.text,_countryCtrl.text);
                        if(authVM.user!=null &&mounted){
                          Navigator.popAndPushNamed(context, '/profile');
                        }
                        else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sign Up failed'))
                          );
                        }
                      }
                    },
                    child: authVM.isLoading?CircularProgressIndicator():Text('Sign Up')
                  ),
                  SizedBox(height: 20,),
                  TextButton(onPressed: (){
                    Navigator.popAndPushNamed(context, '/login');
                  }, child: const Text('Login'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black
                  ),),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}