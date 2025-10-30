import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dioAuth=Dio(BaseOptions(baseUrl: 'http://10.0.2.2:5000/api/auth'));
  final Dio _dioUser=Dio(BaseOptions(baseUrl: 'http://10.0.2.2:5000/api/user'));
  final _storage = const FlutterSecureStorage();

  //Sign up
  Future<bool> register(String username,String email,String password) async{
    try{
      final res=await _dioAuth.post('/register',data: {
        'username':username,
        'email':email,
        'password':password
      });
      return res.statusCode==201;
    }catch(e){
      print('Register error: $e');
      return false;
    }
  }

  //Login
  Future<bool> login(String email,String password) async{
    try{
      final res=await _dioAuth.post('/login',data :{
        'email':email,
        'password':password
      });
      if(res.statusCode==200){
        await _storage.write(key: 'accessToken', value: res.data['accessToken']);
        await _storage.write(key: 'refreshToken', value: res.data['refreshToken']);
        return true;
      }
    }catch(e){
      print('Login error $e');
    }
      return false;
  }

  //profile
  Future<Map<String,dynamic>?> getProfile() async{
    final token=await _storage.read(key: 'accessToken');
    if(token==null) return null;
    try{
      final res=await _dioUser.get('/profile',options: Options(headers:{'Authorization':'Bearer $token'}));
      return res.data;
    }catch(e){
      print('Profile fetch error $e');
      return null;
    }
  
  }
}