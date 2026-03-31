import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/providers/task_provider.dart';

class TaskCreateEditScreen extends ConsumerStatefulWidget {
  final Task? task;

  const TaskCreateEditScreen({super.key, this.task});

  @override
  _TaskCreateEditScreenState createState() => _TaskCreateEditScreenState();
}

class _TaskCreateEditScreenState extends ConsumerState<TaskCreateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskStatus _status;
  int? _blockedById;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _dueDate = DateTime.now();
    _status = TaskStatus.todo;
    _initializeFields();
  }

  Future<void> _initializeFields() async {
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _status = widget.task!.status;
      _blockedById = widget.task!.blockedById;
    } else {
      await _loadDraft();
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    _titleController.text = prefs.getString('draft_title') ?? '';
    _descriptionController.text = prefs.getString('draft_description') ?? '';
    final dueDateString = prefs.getString('draft_due_date');
    if (dueDateString != null) _dueDate = DateTime.parse(dueDateString);
    final statusString = prefs.getString('draft_status');
    if (statusString != null) _status = TaskStatus.fromString(statusString);
    _blockedById = prefs.getInt('draft_blocked_by_id');
  }

  Future<void> _saveDraft() async {
    if (widget.task != null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_title', _titleController.text);
    await prefs.setString('draft_description', _descriptionController.text);
    await prefs.setString('draft_due_date', _dueDate.toIso8601String());
    await prefs.setString('draft_status', _status.label);
    if (_blockedById != null) {
      await prefs.setInt('draft_blocked_by_id', _blockedById!);
    } else {
      await prefs.remove('draft_blocked_by_id');
    }
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_title');
    await prefs.remove('draft_description');
    await prefs.remove('draft_due_date');
    await prefs.remove('draft_status');
    await prefs.remove('draft_blocked_by_id');
  }

  @override
  void dispose() {
    _saveDraft();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() => _dueDate = pickedDate);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final task = Task(
        id: widget.task?.id ?? 0,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        status: _status,
        blockedById: _blockedById,
      );

      try {
        if (widget.task == null) {
          await ref.read(tasksProvider.notifier).addTask(task);
        } else {
          await ref.read(tasksProvider.notifier).updateTask(task);
        }
        await _clearDraft();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.task == null
                  ? 'Task created successfully '
                  : 'Task updated successfully '),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider).asData?.value ?? [];
    // Exclude current task from dependency list to avoid self-blocking
    final otherTasks =
        tasks.where((t) => widget.task == null || t.id != widget.task!.id).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          widget.task == null ? 'Create Task' : 'Edit Task',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'What needs to be done?',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.task_alt, color: Colors.blueAccent),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Add more details about this task...',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.notes, color: Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Settings',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.calendar_today,
                                color: Colors.blueAccent, size: 20),
                          ),
                          title: const Text('Due Date',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(DateFormat('EEEE, MMM d').format(_dueDate)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _pickDate,
                        ),
                        Divider(height: 1, color: Colors.grey.shade100),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.flag_rounded,
                                color: Colors.orangeAccent, size: 20),
                          ),
                          title: const Text('Status',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(_status.label),
                          trailing: PopupMenuButton<TaskStatus>(
                            icon: const Icon(Icons.arrow_drop_down),
                            onSelected: (val) => setState(() => _status = val),
                            itemBuilder: (ctx) => TaskStatus.values
                                .map((s) => PopupMenuItem(
                                    value: s, child: Text(s.label)))
                                .toList(),
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey.shade100),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.lock_clock,
                                color: Colors.redAccent, size: 20),
                          ),
                          title: const Text('Blocked By',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(_blockedById == null
                              ? 'No dependencies'
                              : otherTasks
                                  .firstWhere((t) => t.id == _blockedById,
                                      orElse: () => Task(
                                          id: 0,
                                          title: 'Unknown',
                                          description: '',
                                          dueDate: DateTime.now(),
                                          status: TaskStatus.todo))
                                  .title),
                          trailing: PopupMenuButton<int?>(
                            icon: const Icon(Icons.arrow_drop_down),
                            onSelected: (val) =>
                                setState(() => _blockedById = val),
                            itemBuilder: (ctx) => [
                              const PopupMenuItem<int?>(
                                  value: null, child: Text('None')),
                              ...otherTasks.map((t) => PopupMenuItem<int?>(
                                  value: t.id, child: Text(t.title))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.task == null ? 'Create Task' : 'Save Changes',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
