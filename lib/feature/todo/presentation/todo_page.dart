import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo/feature/todo/domain/todo.dart';
import 'package:todo/feature/todo/domain/todo_failure.dart';
import 'package:todo/feature/todo/presentation/todo_widget.dart';

import 'todo_cubit.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late final TodoCubit _cubit;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _cubit = context.read<TodoCubit>();
      _cubit.getTodosRequested();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TodoCubit, TodoState>(
          listener: (_, state) => onCreateFailure(state.createFailure),
          listenWhen: (prev, cur) => prev.createFailure != cur.createFailure,
        ),
        BlocListener<TodoCubit, TodoState>(
          listener: (_, state) => onUpdateFailure(state.updateFailure),
          listenWhen: (prev, cur) => prev.updateFailure != cur.updateFailure,
        ),
        BlocListener<TodoCubit, TodoState>(
          listener: (_, state) => onDeleteFailure(state.deleteFailure),
          listenWhen: (prev, cur) => prev.deleteFailure != cur.deleteFailure,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text('Todo'), elevation: 0),
        body: BlocBuilder<TodoCubit, TodoState>(
          buildWhen: (prev, cur) =>
              prev.todos != cur.todos || prev.onProcessing != cur.onProcessing,
          builder: (_, state) {
            return buildTodos(state.todos);
          },
        ),
        floatingActionButton: BlocBuilder<TodoCubit, TodoState>(
          buildWhen: (prev, cur) => prev.status != cur.status,
          builder: (_, state) => FloatingActionButton(
            elevation: 0,
            onPressed: state.status
                .maybeMap(orElse: () => null, idle: (_) => showFormInput),
            child: state.status.maybeMap(
              orElse: () => const Icon(Icons.add),
              busy: (_) => const CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTodos(List<Todo>? todos) {
    if (todos?.isEmpty ?? true) return Center(child: const Text('Empty list'));

    return ListView.builder(
      itemCount: todos!.length,
      itemBuilder: (_, i) {
        final todo = todos[i];
        final enabled = _cubit.state.containsId(todo.id);

        return TodoTile(
          todo: todo,
          enabled: !enabled,
          key: Key(todo.id.value.fold((l) => '####', (r) => r)),
          onDelete: () {
            _cubit.deleted(todo.id);
          },
          onCheckChanged: (checked) {
            checked ? _cubit.markDone(todo) : _cubit.markUnDone(todo);
          },
        );
      },
    );
  }

  void showError(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      action: SnackBarAction(
        label: 'Reload',
        onPressed: () => _cubit.getTodosRequested(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _cubit.clearFailure();
  }

  void onCreateFailure(TodoFailure? failure) {
    if (failure == null) return;

    showError(failure.maybeMap(orElse: () => 'Unable add todo'));
  }

  void onUpdateFailure(TodoFailure? failure) {
    if (failure == null) return;

    showError(failure.maybeMap(orElse: () => 'Unable update todo'));
  }

  void onDeleteFailure(TodoFailure? failure) {
    if (failure == null) return;

    showError(failure.maybeMap(orElse: () => 'Unable delete todo'));
  }

  showFormInput() {
    // return _cubit.created(TodoTask(''));
    // ignore: dead_code
    return showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => Container(
        margin: EdgeInsets.all(48).copyWith(top: 150),
        child: Column(
          children: [
            TodoNameInput(
              onSaved: (task) {
                Navigator.of(context).pop();
                _cubit.created(task);
              },
            ),
          ],
        ),
      ),
    );
  }
}
