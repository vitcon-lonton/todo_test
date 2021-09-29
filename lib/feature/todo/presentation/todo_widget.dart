import 'package:flutter/material.dart';
import 'package:todo/feature/todo/domain/todo.dart';
import 'package:todo/feature/todo/domain/value_objects.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final bool enabled;
  final VoidCallback? onDone;
  final VoidCallback? onDelete;
  final void Function(bool)? onCheckChanged;

  const TodoTile({
    Key? key,
    required this.todo,
    required this.enabled,
    this.onDone,
    this.onDelete,
    this.onCheckChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final done = todo.done;

    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        ListTile(
          title: Text(todo.task.getOrCrash()),
          leading: IconButton(
            onPressed: () {
              if (onCheckChanged == null) return;
              onCheckChanged!(!done);
            },
            icon: Icon(
              done ? Icons.check_box : Icons.check_box_outline_blank_outlined,
            ),
          ),
          trailing: IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_forever_outlined),
          ),
        ),
        if (!enabled)
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(color: Colors.black12)),
        if (!enabled)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}

class TodoNameInput extends StatefulWidget {
  final void Function(TodoTask)? onSaved;

  const TodoNameInput({
    Key? key,
    this.onSaved,
  }) : super(key: key);

  @override
  State<TodoNameInput> createState() => _TodoNameInputState();
}

class _TodoNameInputState extends State<TodoNameInput> {
  late bool dirty;
  late TodoTask task;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    dirty = false;
    task = TodoTask('');
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          child: Column(
            children: [
              const SizedBox(height: 36),
              Container(
                child: TextFormField(
                  maxLines: 10,
                  controller: controller,
                  onChanged: (value) {
                    setState(() {
                      dirty = true;
                      task = TodoTask(value);
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    errorText: !dirty
                        ? null
                        : task.value.fold(
                            (f) => f.maybeMap(
                                orElse: () => 'Task Invalid',
                                empty: (_) => 'Task must be not empty',
                                exceedingLength: (_) => 'Task is to long'),
                            (r) => null,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Container(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                      elevation: 0, shadowColor: Colors.transparent),
                  onPressed: task.value.fold(
                    (f) => null,
                    (r) => () {
                      if (widget.onSaved == null) return;
                      widget.onSaved!(task);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
