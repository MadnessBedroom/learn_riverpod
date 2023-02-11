import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@immutable
class TodoMo {
  const TodoMo({
    required this.id,
    required this.description,
    required this.completed,
  });

  // 在我们的类中所有的属性都应该是 `final` 的。
  final String id;
  final String description;
  final bool completed;

  // 由于Todo是不可变的，我们实现了一种方法允许克隆内容略有不同的Todo。
  TodoMo copyWith({String? id, String? description, bool? completed}) {
    return TodoMo(
      id: id ?? this.id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
}

class TodoNotifier extends Notifier<List<TodoMo>> {
  @override
  List<TodoMo> build() {
    return [
      const TodoMo(id: '1', description: 'coding', completed: true),
      const TodoMo(id: '2', description: 'learning', completed: false),
      const TodoMo(id: '3', description: 'running', completed: false),
    ];
  }

  void addTodo(TodoMo todo) {
    /// 因为状态是不可变的，不允许使用 `state.add` 这些方式修改状态
    state = [...state, todo];
  }

  void removeTodo(String todoId) {
    state = state.where((element) => element.id != todoId).toList();
  }

  void completed(String todoId) {
    state = [
      for (final todo in state)
        // 我们只标记完成的待办清单
        if (todo.id == todoId)
          // 再一次因为我们的状态是不可变的，所以我们需要创建待办清单的副本，
          // 我们使用之前实现的copyWith方法来实现。
          todo.copyWith(completed: !todo.completed)
        else
          // 其他未修改的待办清单
          todo,
    ];
  }
}

// 最后，我们使用NotifierProvider来允许UI与我们的TodosNotifier类交互。
final todosProvider = NotifierProvider<TodoNotifier, List<TodoMo>>(() {
  return TodoNotifier();
});

class TodoList extends HookConsumerWidget {
  const TodoList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TodoMo> todos = ref.watch(todosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TodoList'),
      ),
      body: ListView(
        children: [
          for (final todo in todos)
            CheckboxListTile(
              value: todo.completed,
              onChanged: (value) =>
                  ref.read(todosProvider.notifier).completed(todo.id),
              title: Text(
                todo.description,
                style: TextStyle(
                    decoration:
                        todo.completed ? TextDecoration.lineThrough : null),
              ),
            ),
        ],
      ),
    );
  }
}
