import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db/todo_db.dart';
import 'todo_add.dart';
import 'todo_detail.dart';
import 'todo_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TodoItemDatabase().initDatabase();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TodoListPage(),
        '/add': (context) => const TodoAddPage(),
        '/detail': (context) => const TodoDetailPage(),
      },
    );
  }
}
