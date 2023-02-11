import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const fetchPath = 'https://jsonplaceholder.typicode.com/todos';

@immutable
class TodoMo {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  const TodoMo({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  factory TodoMo.fromJson(Map<String, dynamic> json) => TodoMo(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      completed: json['completed']);
}

class TodosNotifier extends AsyncNotifier<List<TodoMo>> {
  Future<List<TodoMo>> _fetchTodo() async {
    final response = await Dio().get(fetchPath);
    final data = response.data;
    return (data as List).map((e) => TodoMo.fromJson(e)).toList();
  }

  @override
  Future<List<TodoMo>> build() {
    return _fetchTodo();
  }

  // 让我们把待办清单标记为已完成
  Future<void> toggle(int todoId) async {
    // state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Dio().patch(
        '$fetchPath/$todoId',
        data: jsonEncode({'completed': true}),
        options: Options(
          headers: {
            'Content-type': 'application/json; charset=UTF-8',
          },
        ),
      );
      return _fetchTodo();
    });
  }
}

final asyncTodoProvider =
    AsyncNotifierProvider<TodosNotifier, List<TodoMo>>(() => TodosNotifier());

class AsyncTodoList extends HookConsumerWidget {
  const AsyncTodoList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(asyncTodoProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Async Todos'),
      ),
      body: todos.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => CheckboxListTile(
            value: data[index].completed,
            onChanged: (value) =>
                ref.read(asyncTodoProvider.notifier).toggle(data[index].id),
            title: Text(data[index].title),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
