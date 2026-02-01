import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db/todo_db.dart';
import 'providers/todo_item_db.dart';

class TodoAddPage extends ConsumerStatefulWidget {
  const TodoAddPage({super.key});

  @override
  TodoAddPageState createState() => TodoAddPageState();
}

class TodoAddPageState extends ConsumerState<TodoAddPage> {
  final formKey = GlobalKey<FormState>(); // フォーム共通キー
  final titleFormKey = GlobalKey<FormFieldState<String>>(); // タイトルフォームキー
  final contentFormKey = GlobalKey<FormFieldState<String>>(); // 内容フォームキー
  // フォームキーを使って、バリデーションを実行できたり、フォームの入力値を参照できたりする

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Todo 追加'),
      ),
      body: Form(
        key: formKey, // キーを設定
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                padding: EdgeInsets.only(bottom: 48),
                child: TextFormField(
                  key: titleFormKey, // キーを設定
                  decoration: const InputDecoration(
                    labelText: 'タイトル',
                  ),
                  validator: (value) {
                    if (value == null || value.trim() == '') {
                      return '入力してください';
                    }
                    else if (value.length > 30) {
                      return 'タイトルは30文字以下でなければなりません';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                width: 300,
                padding: EdgeInsets.only(bottom: 32),
                child: TextFormField(
                  key: contentFormKey, // キーを設定
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '内容',
                    alignLabelWithHint: true
                  ),
                  minLines: 8,
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim() == '') {
                      return '入力してください';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final title = titleFormKey.currentState?.value ?? '';
                      final content = contentFormKey.currentState?.value ?? '';
                      await TodoItemDatabase().insertTodoItem(title, content);
                      ref.refresh(todoProvider);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Text('Todoを追加')
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}
