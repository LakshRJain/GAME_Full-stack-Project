class UserModel{
  final String? id;
  final String username;
  final String email;
  final String? country;
  final String? gamesPlayed;
  final String? preferredGameMode;
  final String? rank;
  final String? avatarUrl;
  final String? wins;
  
  UserModel({this.id,required this.username,required this.email, this.rank, this.country, this.gamesPlayed, this.avatarUrl, this.preferredGameMode, this.wins});

  factory UserModel.fromJson(Map<String,dynamic> json){
    return UserModel(
      id:json['id'].toString(),
      username:json['username'].toString(),
      email:json['email'].toString(),
      rank: json['rank'].toString(),
      gamesPlayed: json['games_played'].toString(),
      wins: json['wins'].toString(),
      preferredGameMode: json['preferred_game_mode'].toString(),
      country: json['country'].toString(),
      avatarUrl: json['avatar_url'].toString(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "country": country,
      "preferred_game_mode": preferredGameMode,
      "avatar_url": avatarUrl,
    };
  }
  
}