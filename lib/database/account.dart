class Account {
  final int id;
  final String name;
  final String username;
  final String password;
  final String deskripsi;
  final int gameId;

  Account(
      {required this.id,
      required this.name,
      required this.username,
      required this.password,
      required this.deskripsi,
      required this.gameId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'deskripsi': deskripsi,
      'gameId': gameId,
    };
  }

  static Account fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: 'name',
      username: map['username'],
      password: map['password'],
      deskripsi: 'deskripsi',
      gameId: map['gameId'],
    );
  }
}
