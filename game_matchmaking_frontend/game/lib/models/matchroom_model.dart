class MatchRoom {
  final int id;
  final String roomId;
  final String player1Id;
  final String player2Id;
  final String player1Username;
  final String player2Username;
  final String rank;
  final String status;
  final DateTime createdAt;

  MatchRoom({
    required this.id,
    required this.roomId,
    required this.player1Id,
    required this.player2Id,
    required this.player1Username,
    required this.player2Username,
    required this.rank,
    required this.status,
    required this.createdAt,
  });

  factory MatchRoom.fromJson(Map<String, dynamic> json) {
    return MatchRoom(
      id: json['id'],
      roomId: json['room_id'],
      player1Id: json['player1_id'],
      player2Id: json['player2_id'],
      player1Username: json['player1_username'],
      player2Username: json['player2_username'],
      rank: json['rank'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'player1_id': player1Id,
      'player2_id': player2Id,
      'player1_username': player1Username,
      'player2_username': player2Username,
      'rank': rank,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
