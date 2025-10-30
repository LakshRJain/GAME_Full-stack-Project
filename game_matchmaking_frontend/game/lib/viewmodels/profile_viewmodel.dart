import 'package:flutter/material.dart';
import 'package:game/models/user_model.dart';
import 'package:game/services/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier{

  final ProfileRepository _repository = ProfileRepository();
  UserModel? _user;
  bool _isLoading=false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async{
    _isLoading=true;
    notifyListeners();
    try{
      _user=await _repository.fetchProfile();
      print("Fetched");
      print("hi");
      _error=null;
    }catch(e){
      _error=e.toString();
      print(e);
      print("ERROR");
    }finally{
      _isLoading=false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async{
    _isLoading=true;
    notifyListeners();
    try{
      _user=await _repository.updateProfile(updatedUser);
      _error=null;
    }catch(e){
      _error=e.toString();
    }finally{
      _isLoading=false;
      notifyListeners();
    }
  }
}