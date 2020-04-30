import 'dart:async';
import 'dart:io';
import 'package:mytodo/todo.dart';
import 'package:mytodo/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataManager {

  static Database _database;
  DataManager._();
  static DataManager _instance;

  static DataManager getInstance() {
    if(_instance == null)
      _instance = DataManager._();

    return _instance;
  }

  Future<Database> get getDatabase async {
    if(_database != null)
      return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    final db = openDatabase(
      join(await getDatabasesPath(), "my_todo.db"),
      onCreate: (db, version) async {

         var sql = "CREATE TABLE todos ("
             "id INTEGER PRIMARY KEY, "
             "title TEXT NOT NULL, "
             "description TEXT NOT NULL, "
             "date TEXT NOT NULL, "
             "created TEXT NULL"
             ")";
         await db.execute(sql);

         await db.execute(
           "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, password TEXT NOT NULL, email TEXT NOT NULL, created TEXT NULL)"
         );
      },

      version: 1
    );

    return db;
  }

  Future<Todo> todo() async {
    final db = await getDatabase;

    var result = await db.query(
      "todos",
      where: "id = ?",
      whereArgs: [1]
    );

    return (result.isNotEmpty) ? Todo.fromMap(result.first) : null;
  }

  Future<List<Todo>> todos() async {
    final db = await getDatabase;
    var result = await db.query("todos", orderBy: "id ASC");
    List<Todo> todos = new List();
    result.forEach((res) {
      Todo todo = Todo.fromMap(res);
      todos.add(todo);
    });

    return todos;
  }

  Future<List<Todo>> todosToday(String date) async {
    final db = await getDatabase;
    var result = await db.query("todos", where: "date = ?", whereArgs: [date], orderBy: "id ASC");
    List<Todo> todos = new List();
    result.forEach((res) {
      Todo todo = Todo.fromMap(res);
      todos.add(todo);
    });

    return todos;
  }

  Future<void> insert(Todo todo) async {
    final db = await getDatabase;
    await db.insert("todos", todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  saveEmail(String email) async {
    final db = await getDatabase;
    await db.insert("users", {"email": email});
  }

  saveUser(User user) async {
    final db = await getDatabase;
    await db.insert("users", user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> checkEmail(String email) async {
    final db = await getDatabase;
    var result = await db.query("users", where: "email = ?", whereArgs: [email]);
    return (result.isEmpty);
  }

  temp() async {
    final db = await getDatabase;
    await db.execute("DROP TABLE todos");
    var sql = "CREATE TABLE todos ("
        "id INTEGER PRIMARY KEY, "
        "title TEXT NOT NULL, "
        "description TEXT NOT NULL, "
        "date TEXT NOT NULL, "
        "created TEXT NULL"
        ")";
    await db.execute(sql);

    print("Done");
  }
}