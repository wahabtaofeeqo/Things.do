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
    var result = await db.query("todos", orderBy: "id DESC");
    List<Todo> todos = new List();
    result.forEach((res) {
      Todo todo = Todo.fromMap(res);
      todos.add(todo);
    });

    return todos;
  }

  Future<List<Todo>> todosToday(String date) async {
    final db = await getDatabase;
    var result = await db.query("todos", where: "date = ?", whereArgs: [date], orderBy: "id DESC");
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

  users() async {
    final db = await getDatabase;
    var results = await db.query("users", orderBy: "id DESC");

    List<User> users = new List();
    results.forEach((user) {
      User u = User.fromMap(user);
      users.add(u);
    });

    return users;
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

  Future<bool> hasRegister() async {
    final db = await getDatabase;
    var result = await db.query("users");
    return (result.isNotEmpty);
  }

  Future<int> deleteUsers() async {
    final db = await getDatabase;
    return db.delete("users");
  }

  Future<int> deleteTasks() async {
    final db = await getDatabase;
    return db.delete("todos");
  }

  Future<User> getUser(String email) async {
    final db = await getDatabase;
    var result = await db.query("users", where: "email = ?", whereArgs: [email]);
    return User.fromMap(result.first);
  }

  markComplete(int id, int value) async {
    final db = await getDatabase;
    var result = await db.update("todos", {"status": value}, where: "id = ?", whereArgs: [id]);
    return result;
  }
  
  Future<List<Todo>> getTasks(String date, int status) async {
    final db = await getDatabase;
    var result = await db.query("todos", where: "date = ? AND status = ?", whereArgs: [date, status]);
    var list = List.generate(result.length, (i) {
      return Todo.fromMap(result.elementAt(i));
    });

    return list;
  }

  deleteTask(int id) async {
    final db = await getDatabase;
    var result = await db.delete("todos", where: "id = ?", whereArgs: [id]);
    return result;
  }

  temp() async {
    final db = await getDatabase;
    await db.execute("DROP TABLE todos");
    var sql = "CREATE TABLE todos ("
        "id INTEGER PRIMARY KEY, "
        "title TEXT NOT NULL, "
        "description TEXT NOT NULL, "
        "date TEXT NOT NULL, "
        "status INTEGER DEFAULT 0, "
        "created TEXT NULL"
        ")";
    await db.execute(sql);
  }
}