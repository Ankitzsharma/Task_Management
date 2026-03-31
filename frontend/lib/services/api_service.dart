import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../utils/constants.dart';

class ApiService {
  String get _baseUrl => AppConstants.baseUrl;

  Future<List<Task>> getTasks({String? title, String? status}) async {
    var uri = Uri.parse('$_baseUrl/tasks/');
    final Map<String, String> queryParams = {};
    if (title != null && title.isNotEmpty) {
      queryParams['title'] = title;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tasks/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<Task> updateTask(int id, Task task) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/tasks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/tasks/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}
