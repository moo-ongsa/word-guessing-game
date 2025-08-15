class SavedPlayer {
  final String id;
  final String name;
  final DateTime lastUsed;

  SavedPlayer({required this.id, required this.name, required this.lastUsed});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'lastUsed': lastUsed.toIso8601String()};
  }

  factory SavedPlayer.fromJson(Map<String, dynamic> json) {
    return SavedPlayer(
      id: json['id'],
      name: json['name'],
      lastUsed: DateTime.parse(json['lastUsed']),
    );
  }
}
