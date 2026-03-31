import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/providers/task_provider.dart';
import 'package:task_management_app/screens/task_create_edit_screen.dart';
import 'package:task_management_app/widgets/task_card.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(tasksProvider);
    final selectedFilter = ref.watch(statusFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'My Tasks',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (query) {
                    ref.read(tasksProvider.notifier).setSearchQuery(query);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                          label: 'All',
                          value: null,
                          isSelected: selectedFilter == null),
                      _FilterChip(
                          label: 'To-Do',
                          value: 'To-Do',
                          isSelected: selectedFilter == 'To-Do'),
                      _FilterChip(
                          label: 'In Progress',
                          value: 'In Progress',
                          isSelected: selectedFilter == 'In Progress'),
                      _FilterChip(
                          label: 'Done',
                          value: 'Done',
                          isSelected: selectedFilter == 'Done'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasksAsyncValue.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.rocket_launch_rounded,
                                size: 80,
                                color: Colors.blueAccent.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No tasks yet 🚀',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your task list is empty. Start by creating your first task to stay organized!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                height: 1.5),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const TaskCreateEditScreen()),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create My First Task'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(tasksProvider.notifier).fetchTasks(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(task: tasks[index]);
                    },
                  ),
                );
              },
              loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.blueAccent),
                    const SizedBox(height: 16),
                    Text('Loading your tasks...',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.error_outline_rounded,
                            size: 60, color: Colors.redAccent),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We couldn\'t load your tasks. Please check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(tasksProvider.notifier).fetchTasks(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                          side: const BorderSide(color: Colors.blueAccent),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TaskCreateEditScreen()),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _FilterChip extends ConsumerWidget {
  final String label;
  final String? value;
  final bool isSelected;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          ref.read(tasksProvider.notifier).setStatusFilter(value);
        },
        selectedColor: Colors.blueAccent.withOpacity(0.2),
        checkmarkColor: Colors.blueAccent,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.blueAccent : Colors.black87,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
