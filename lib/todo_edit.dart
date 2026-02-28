import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import './providers/todo_item_db.dart';
import './db/todo_db.dart';

class TodoEditPage extends ConsumerStatefulWidget {
  const TodoEditPage({super.key});

  @override
  ConsumerState<TodoEditPage> createState() => _TodoEditPageState();
}

class _TodoEditPageState extends ConsumerState<TodoEditPage> {
  final database = TodoItemDatabase();
  final formKey = GlobalKey<FormState>();
  final titleFormKey = GlobalKey<FormFieldState<String>>();
  final contentFormKey = GlobalKey<FormFieldState<String>>();
  int selectedValue = 0;
  final radioLabels = ['高', '中', '低'];
  final deadlineController = TextEditingController();
  Map<String, dynamic> formValue = {};

  @override
  void dispose() {
    deadlineController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final todo = ModalRoute.of(context)!.settings.arguments as TodoItem;
    selectedValue = todo.priority;
    deadlineController.text = deadlineController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(todo.deadline);
  }

  @override
  Widget build(BuildContext context) {
    final todo = ModalRoute.of(context)!.settings.arguments as TodoItem;
    return Scaffold(
      appBar: AppBar(title: const Text('Todo 編集')),
      body: Form(
        key: formKey,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                padding: const EdgeInsets.all(4),
                width: 300,
                child: TextFormField(
                  key: titleFormKey,
                  initialValue: todo.title,
                  decoration: const InputDecoration(labelText: 'タイトル'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'タイトルを入力してください。';
                    } else if (value.length > 30) {
                      return 'タイトルは30文字以内で入力してください。';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                padding: const EdgeInsets.all(4),
                width: 300,
                height: 200,
                child: TextFormField(
                  key: contentFormKey,
                  initialValue: todo.content,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '内容',
                    alignLabelWithHint: true,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 8,
                  validator: (value) {
                    return value == null || value.isEmpty
                        ? '内容を入力してください。'
                        : null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                width: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final radioButtonValue in [0, 1, 2])
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio(
                            value: radioButtonValue,
                            groupValue: selectedValue,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value ?? 0;
                              });
                            },
                          ),
                          Text(radioLabels[radioButtonValue]),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                padding: const EdgeInsets.all(4),
                width: 300,
                child: TextFormField(
                  controller: deadlineController,
                  decoration: const InputDecoration(labelText: 'Deadline'),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
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
                  validator: (value) {
                    return value == null || value.isEmpty
                        ? '期限を決めてください。'
                        : null;
                  },
                ),
              ),
              SizedBox(
                width: 300,
                height: 40,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // ユーザーがタイトルフォームで入力した値
                      final title = titleFormKey.currentState?.value ?? '';
                      // ユーザーが内容フォームで入力した値
                      final content = contentFormKey.currentState?.value ?? '';
                      final deadline = deadlineController.text;
                      await TodoItemDatabase().updateTodoItem(
                        todo.id,
                        title,
                        content,
                        selectedValue,
                        deadline,
                      );
                      ref.refresh(todoProvider);
                      ref.refresh(todoDetailProvider(todo.id));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Todo を編集'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
