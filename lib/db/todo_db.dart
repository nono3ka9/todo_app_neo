import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodoItemDatabase {
  //クラスからインスタンスを１つしか作れない
  factory TodoItemDatabase() => _instance;
  TodoItemDatabase._internal();
  static final TodoItemDatabase _instance = TodoItemDatabase._internal();

  late final Database database;

  Future<Database> initDatabase() async {
    const scripts = {
      1: [
        'CREATE TABLE TodoItem(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, isCompleted INTEGER);',
      ],
      2: ['ALTER TABLE TodoItem ADD COLUMN priority INTEGER DEFAULT 1;'],
      3: [
        "ALTER TABLE TodoItem ADD COLUMN deadline TEXT DEFAULT '1970-01-01T00:00:00.000Z';",
      ],
    };

    //データベースに接続
    database = await openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) async {
        for (var i = oldVersion + 1; i <= newVersion; i++) {
          final queries = scripts[i] ?? [];
          for (final query in queries) {
            await db.execute(query);
          }
        }
      },
    );
    return database;
  }

  //データベースからTodoを全部とってくる
  Future<List<TodoItem>> getTodoItems() async {
    final List<Map<String, dynamic>> rows = await database.query('TodoItem');
    return rows.map((item) {
      return TodoItem(
        id: item['id'],
        title: item['title'],
        content: item['content'],
        isCompleted: item['isCompleted'] == 1,
        priority: item['priority'],
        deadline: DateTime.parse(item['deadline']),
      );
    }).toList();
  }

  //データベースからID指定してTodoを１つ取ってくる
  Future<TodoItem> getTodoItemById(int id) async {
    final List<Map<String, dynamic>> row = await database.query(
      'TodoItem',
      where: 'id = ?',
      whereArgs: [id],
    );
    return TodoItem(
      id: id,
      title: row[0]['title'],
      content: row[0]['content'],
      isCompleted: row[0]['isCompleted'] == 1,
      priority: row[0]['priority'],
      deadline: DateTime.parse(row[0]['deadline']),
    );
  }

  //データベースにTodoを追加する
  Future<void> insertTodoItem(
    String title,
    String content,
    int? priority,
    String deadline,
  ) async {
    await database.insert('TodoItem', {
      'title': title,
      'content': content,
      'isCompleted': 0,
      'priority': priority, // デフォルト値を設定
      'deadline': deadline,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  //データベースのTodoの完了未完了を更新する
  Future<void> changeTodoItem(int id, bool isCompleted) async {
    await database.update(
      'TodoItem',
      {'isCompleted': isCompleted ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete() async {
    await deleteDatabase(join(await getDatabasesPath(), 'database.db'));
  }

  Future<void> updateTodoItem(
    int id,
    String title,
    String content,
    int? priority,
    String deadline,
  ) async {
    await database.update(
      'TodoItem',
      {
        'title': title,
        'content': content,
        'priority': priority, // デフォルト値を設定
        'deadline': deadline,
      },
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

class TodoItem {
  TodoItem({
    required this.id,
    required this.title,
    required this.content,
    required this.isCompleted,
    required this.priority,
    required this.deadline,
  });

  final int id;
  final String title;
  final String content;
  final bool isCompleted;
  final int priority;
  final DateTime deadline;
}
