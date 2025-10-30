import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:game/models/user_model.dart';

class ProfileRepository {
  final _dio=Dio(BaseOptions(baseUrl: "http://10.0.2.2:5000/api/user"));
  final _storage= FlutterSecureStorage();

  Future<UserModel> fetchProfile() async{
    final token=await _storage.read(key: 'accessToken');
    final response=await _dio.get(
      '/profile',
      options: Options(headers: {"Authorization":"Bearer $token"}),
    );
    print("backend");
    print(response.data);
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateProfile(UserModel updatedUser) async {
    final token=await _storage.read(key: 'accessToken');
    final response =await _dio.put(
      '/profile',
      options: Options(headers: {"Authorization":"Bearer $token"}),
      data: updatedUser.toJson()
    );
    return UserModel.fromJson(response.data);
  }



}