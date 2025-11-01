
import 'package:flutter/material.dart';
import 'package:game/models/user_model.dart';
import 'package:game/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier{
  final AuthService _authService=AuthService();
  UserModel? _user;
  bool _isLoading=false;

  UserModel? get user =>_user;
  bool get isLoading => _isLoading;

  Future<void> register(String username,String email,String password,String country) async{
    _isLoading=true;
    String rank='Iron';
    final avatarUrl='https://gravatar.com/avatar/6b6b69da5c88718d32bc60e754f59ed9?s=400&d=robohash&r=x';
    notifyListeners();
    final success = await _authService.register(username, email, password, country,rank,avatarUrl);

    if(success){
      await login(email, password);
    }
    _isLoading=false;
    notifyListeners();
  }

  Future<void> login(String email,String password) async{
    _isLoading=true;
    notifyListeners();
    final success= await _authService.login(email, password);
    if(success){
      final profile=await _authService.getProfile();
      if(profile!=null) _user=UserModel.fromJson(profile);
    }
    _isLoading=false;
    notifyListeners();
  }
}