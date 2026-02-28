import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db/todo_db.dart';
import 'providers/todo_item_db.dart';
import 'package:intl/intl.dart';

class TodoDetailPage extends ConsumerWidget {
  const TodoDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Navigatorで渡された引数を取得（TodoのID）
    final todoId = ModalRoute.settingsOf(context)!.arguments as int;
    // FlutterProviderで、ID指定してTodoを取ってくる
    final todoAsync = ref.watch(todoDetailProvider(todoId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Todo 詳細'),

        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('削除確認'),
                  content: const Text('このTodoを削除しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        '削除',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (result == true) {
                await TodoItemDatabase().deleteTodoItem(todoId);

                ref.refresh(todoProvider);

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
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
                    child: Text(data.title),
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
                    child: Text(data.content),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    data.priority == 0
                        ? '優先度：高'
                        : data.priority == 1
                        ? '優先度：中'
                        : '優先度：低',
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    '期限： ${DateFormat('yyyy年MM月dd日').format(data.deadline)}',
                  ),
                ),
                SizedBox(
                  width: 300,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      await TodoItemDatabase().changeTodoItem(
                        todoId,
                        data.isCompleted,
                      );
                      ref
                        ..refresh(todoProvider)
                        ..invalidate(todoDetailProvider);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: data.isCompleted ? Text('未完了にする') : Text('完了にする'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  height: 40,
                  child: ElevatedButton(
                    child: const Text('編集する'),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/edit', arguments: data);
                    },
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
