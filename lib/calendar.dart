import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import 'db/todo_db.dart';
import 'providers/todo_item_db.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});
  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  // 表示している日付
  // (_focusedDayを含む月が画面上に表示されている)
  DateTime _focusedDay = DateTime.now();
  // 選択されている日付
  DateTime? _selectedDay;

  List<TodoItem> _getFilteredTodo(List<TodoItem> todoItemList) {
    if (_selectedDay == null) {
      return [];
    }
    return todoItemList.where((todo) {
      return isSameDay(_selectedDay, todo.deadline);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allTodoAsync = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('カレンダー')),
      body: Column(
        children: [
          TableCalendar(
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 10, 16),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              // 「選択されている日付」を決定する条件
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              // 「選択されている日付」を、_selectedDay変数を使って回収している
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          allTodoAsync.when(
            error: (err, _) => Text('$err'),
            loading: () => CircularProgressIndicator(),
            data: (data) {
              // dataには、「データベースからとってきたすべてのTodoのリスト」が入る
              final filterdTodo = _getFilteredTodo(data);
              if (_selectedDay == null) {
                return const Text('日付の選択がされていません');
              }

              if (filterdTodo.isEmpty) {
                return const Text('この日が期限のTodoはありません');
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: filterdTodo.length,
                  itemBuilder: (context, index) {
                    final todoItem = filterdTodo[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          '${index + 1} ${todoItem.title}',
                          style: TextStyle(
                            decoration: todoItem.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: todoItem.isCompleted
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
