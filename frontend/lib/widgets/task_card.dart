import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/providers/task_provider.dart';
import 'package:task_management_app/screens/task_create_edit_screen.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  Widget _highlightText(String text, String query, BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87));
    }

    final matches = query.toLowerCase();
    final parts = text.split(RegExp(matches, caseSensitive: false));

    if (parts.length <= 1) {
      return Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87));
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        children: parts.asMap().entries.map((entry) {
          final index = entry.key;
          final part = entry.value;
          final List<InlineSpan> spans = [TextSpan(text: part)];

          if (index < parts.length - 1) {
            final matchStart = text.toLowerCase().indexOf(
                matches,
                parts.sublist(0, index + 1).join(matches).length -
                    matches.length);
            final matchedText =
                text.substring(matchStart, matchStart + query.length);
            spans.add(TextSpan(
              text: matchedText,
              style: TextStyle(
                  backgroundColor: Colors.yellow.shade200, color: Colors.black),
            ));
          }
          return spans;
        }).expand((e) => e).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider).asData?.value ?? [];
    final searchQuery = ref.watch(tasksProvider.notifier).searchQuery;

    final blockingTask = task.blockedById != null
        ? tasks.where((t) => t.id == task.blockedById).firstOrNull
        : null;

    final isBlocked =
        blockingTask != null && blockingTask.status != TaskStatus.done;

    return Card(
      elevation: isBlocked ? 0 : 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Opacity(
        opacity: isBlocked ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isBlocked ? Colors.grey.shade100 : Colors.white,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isBlocked
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🔒 This task is blocked by "${blockingTask!.title}"'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                  }
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskCreateEditScreen(task: task),
                      ),
                    );
                  },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _highlightText(task.title, searchQuery, context),
                      ),
                      _StatusChip(status: task.status),
                    ],
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat.yMMMd().format(task.dueDate),
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (isBlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock,
                                      size: 12, color: Colors.redAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Blocked by ${blockingTask.title}',
                                    style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent, size: 20),
                            onPressed: () {
                              _showDeleteConfirm(context, ref);
                            },
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(task.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withOpacity(0.5)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
