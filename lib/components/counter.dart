import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final countProvider = StateProvider<int>((ref) {
  return 0;
});

class Counter extends HookConsumerWidget {
  const Counter({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: Text(
          ref.watch(countProvider).toString(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.watch(countProvider.notifier).state++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
