import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'db/todo_db.dart';
import 'providers/todo_item_db.dart';
import 'services/notification_schedule.dart';

class TodoAddPage extends ConsumerStatefulWidget {
  const TodoAddPage({super.key});

  @override
  TodoAddPageState createState() => TodoAddPageState();
}

class TodoAddPageState extends ConsumerState<TodoAddPage> {
  int? selectedValue = 1; // プライオリティの初期値
  final formKey = GlobalKey<FormState>(); // フォーム共通キー
  final titleFormKey = GlobalKey<FormFieldState<String>>(); // タイトルフォームキー
  final contentFormKey = GlobalKey<FormFieldState<String>>(); // 内容フォームキー
  // フォームキーを使って、バリデーションを実行できたり、フォームの入力値を参照できたりする

  final deadlineController = TextEditingController();

  @override
  void dispose() {
    deadlineController.dispose();
    super.dispose();
  }

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
                  decoration: const InputDecoration(labelText: 'タイトル'),
                  validator: (value) {
                    if (value == null || value.trim() == '') {
                      return '入力してください';
                    } else if (value.length > 30) {
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
                    alignLabelWithHint: true,
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
              RadioGroup(
                groupValue: selectedValue,
                onChanged: (int? value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<int>(
                          value: 0,
                          groupValue: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value;
                            });
                          },
                        ),
                        const Text('高'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<int>(
                          value: 1,
                          groupValue: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value;
                            });
                          },
                        ),
                        const Text('中'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<int>(
                          value: 2,
                          groupValue: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value;
                            });
                          },
                        ),
                        const Text('低'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 300,
                padding: EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: deadlineController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Deadline'),
                  onTap: () async {
                    FocusScope.of(
                      context,
                    ).requestFocus(FocusNode()); // キーボードを非表示
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      deadlineController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(selectedDate);
                    }
                  },
                ),
              ),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // ユーザーがタイトルフォームで入力した値
                      final title = titleFormKey.currentState?.value ?? '';
                      // ユーザーが内容フォームで入力した値
                      final content = contentFormKey.currentState?.value ?? '';
                      final deadline = deadlineController.text;
                      final id = await TodoItemDatabase().insertTodoItem(
                        title,
                        content,
                        selectedValue,
                        deadline,
                      );
                      await NotificationSchedule().schedule(
                        id,
                        deadline,
                        title,
                      );
                      ref.refresh(todoProvider);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Text('Todoを追加'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
