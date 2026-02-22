import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db/todo_db.dart';
import 'providers/bottom_nav.dart';
import 'providers/todo_item_db.dart';

class TodoListPage extends ConsumerStatefulWidget {
  const TodoListPage({super.key});

  @override
  TodoListPageState createState() => TodoListPageState();
}

class TodoListPageState extends ConsumerState {
  @override
  Widget build(BuildContext context) {
    final bottomIndex = ref.watch(intPovider);
    final allTodoAsync = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: allTodoAsync.when(
          loading: () => Text('取得中...'),
          error: (error, stackTrace) => Text('$error'),
          data: (data) => Text(
            'Todo 一覧（完了済み${data.where((todo) => todo.isCompleted).length}/${data.length}）',
          ),
        ),
      ),
      body: allTodoAsync.when(
        loading: () => CircularProgressIndicator(),
        error: (error, stackTrace) => Text('$error'),
        data: (data) {
          print(data);
          // 「data」には、FlutterProviderの結果が入る（取ってきた全てのTodo）

          // 完了済みだけをリストにしている
          final completedList = data.where((todo) {
            return todo.isCompleted;
          }).toList();
          // 未完了だけをリストにしている
          final unCompletedList = data.where((todo) {
            return !todo.isCompleted;
          }).toList();
          // bottomIndexが0ならば、shownList = unCompletedlist、1ならば、shownList = completedList
          final shownList = bottomIndex == 0 ? unCompletedList : completedList;

          // ListViewは、リストを作るウィジェット
          // for文みたいなもので、indexが0,1...と変わっていく
          return ListView.builder(
            itemCount: shownList.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                title: Text(shownList[index].title),
                trailing: Checkbox(
                  value: shownList[index].isCompleted,
                  onChanged: (value) async {
                    await TodoItemDatabase().changeTodoItem(
                      shownList[index].id,
                      shownList[index].isCompleted,
                    );
                    ref
                      ..invalidate(todoProvider)
                      ..invalidate(todoDetailProvider);
                  },
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/detail',
                    arguments: shownList[index].id,
                  ); // TodoのIDを渡す
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add');
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.unpublished), label: '未完了'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: '完了'),
        ],
        onTap: (value) {
          ref.read(intPovider.notifier).change(value);
        },
        currentIndex: bottomIndex,
      ),
    );
  }
}
