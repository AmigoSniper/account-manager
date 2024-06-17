class Game {
  final int id;
  final String name;
  final String photo;

  Game({required this.id, required this.name, required this.photo});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'photo': photo};
  }

  static Game fromMap(Map<String, dynamic> map) {
    return Game(id: map['id'], name: map['name'], photo: map['photo']);
  }
}
