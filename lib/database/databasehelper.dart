import 'package:sqflite/sqflite.dart';
import 'account.dart';
import 'game.dart';

class Databasehelper {
  static final Databasehelper instance = Databasehelper._init();
  static Database? _database;

  Databasehelper._init();

  Future<Database> _initDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = dbpath + filepath;
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const gameTable = '''
    CREATE TABLE Games(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      photo TEXT NULL
    )
    ''';

    const accountTable = '''
    CREATE TABLE Accounts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      deskripsi TEXT NULL,
      gameId INTEGER NOT NULL,
      FOREIGN KEY (gameId) REFERENCES games (id)
    )
 ''';

    await db.execute(gameTable);
    await db.execute(accountTable);
  }

  Future<Database> getdatabase() async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDB('game_accounts.db');
      return _database!;
    }
  }

  //add game and account
  Future<int> insertGame(Game game) async {
    final db = await getdatabase();
    return await db.insert('Games', game.toMap());
  }

  Future<int> insertAccount(Account account) async {
    final db = await getdatabase();
    return await db.insert('Accounts', account.toMap());
  }

  //get games and account
  Future<List<Map<String, dynamic>>> getAllGames() async {
    final db = await getdatabase();
    return await db.query('games', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getAccountsByGameId(int gameId) async {
    final db = await getdatabase();
    return await db.query('Accounts',
        where: 'gameId = ?', whereArgs: [gameId], orderBy: 'name ASC');
  }

  //delete games and account
  Future<int> deleteGame(int id) async {
    final db = await getdatabase();
    await db.delete(
      'Accounts',
      where: 'gameId = ?',
      whereArgs: [id],
    );
    return await db.delete(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await getdatabase();
    return await db.delete(
      'Accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //update account and game
  Future<int> updateGame(Map<String, dynamic> game) async {
    final db = await getdatabase();
    final id = game['id'];
    return await db.update(
      'games',
      game,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateAccount(Map<String, dynamic> account) async {
    final db = await getdatabase();
    final id = account['id'];
    return await db.update(
      'Accounts',
      account,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
