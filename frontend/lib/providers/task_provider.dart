import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final statusFilterProvider = StateProvider<String?>((ref) => null);

final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  return TasksNotifier(ref, ref.watch(apiServiceProvider));
});

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final Ref _ref;
  final ApiService _apiService;
  String _searchQuery = '';
  Timer? _debounce;

  String get searchQuery => _searchQuery;

  TasksNotifier(this._ref, this._apiService)
      : super(const AsyncValue.loading()) {
    fetchTasks(isInitial: true);
  }

  Future<void> fetchTasks({bool isInitial = false}) async {
    if (!isInitial) {
      state = const AsyncValue.loading();
    }
    try {
      final statusFilter = _ref.read(statusFilterProvider);
      final tasks =
          await _apiService.getTasks(title: _searchQuery, status: statusFilter);
      state = AsyncValue.data(tasks);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query;
      fetchTasks();
    });
  }

  void setStatusFilter(String? status) {
    _ref.read(statusFilterProvider.notifier).state = status;
    fetchTasks();
  }

  Future<void> addTask(Task task) async {
    try {
      await _apiService.createTask(task);
      fetchTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _apiService.updateTask(task.id, task);
      fetchTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _apiService.deleteTask(id);
      fetchTasks();
    } catch (e) {
      rethrow;
    }
  }
}
