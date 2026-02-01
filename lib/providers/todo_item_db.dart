import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/todo_db.dart';

final todoProvider = FutureProvider(
  (_) => TodoItemDatabase().getTodoItems()
);

final todoDetailProvider = FutureProvider.family<TodoItem, int>(
  (_, id) => TodoItemDatabase().getTodoItemById(id)
);
