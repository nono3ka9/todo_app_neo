import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db/todo_db.dart';
import 'providers/todo_item_db.dart';

class TodoDetailPage extends ConsumerWidget {
  const TodoDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoId = ModalRoute.settingsOf(context)!.arguments as int;
    final todoAsync = ref.watch(todoDetailProvider(todoId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Todo 詳細'),
      ),
      body: todoAsync.when(
        loading: () => CircularProgressIndicator(),
        error: (error, stackTrace) => Text('$error'),
        data: (data) => Center(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: const Text('タイトル'),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    width: 300,
                    child: Text(data.title)
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: const Text('内容'),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 300,
                    height: 200,
                    child: Text(data.content)
                  ),
                ),
                SizedBox(
                  width: 300,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      await TodoItemDatabase().changeTodoItem(todoId, data.isCompleted);
                      ref..refresh(todoProvider)..invalidate(todoDetailProvider);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: data.isCompleted ? Text('未完了にする') : Text('完了にする'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
