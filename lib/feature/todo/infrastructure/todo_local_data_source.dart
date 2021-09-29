import 'package:collection/src/iterable_extensions.dart';
import 'package:todo/core/exceptions.dart';

import 'todo_dtos.dart';

abstract class ITodoLocalDataSource {
  Future<List<TodoDto>> getAllTodo();

  ///Throws [DataBaseException] if create failed
  Future<TodoDto> create(String name);

  ///Throws [DataBaseException] if delete failed
  Future<TodoDto> delete(String id);

  ///Throws [DataBaseException] if update failed
  Future<TodoDto> update(TodoDto todo);

  ///Throws [DataBaseException] if no data found
  Future<TodoDto> getTodo(String id);
}

class TodoLocalDataSource implements ITodoLocalDataSource {
  // final duration = const Duration(milliseconds: 200);
  final duration = const Duration(seconds: 1);

  TodoLocalDataSource();

  List<TodoDto> todos = [
    TodoDto.initial('Reading cached asset graph.'),
    TodoDto.initial('task2'),
    TodoDto.initial('task3'),
    TodoDto.initial('task4'),
    TodoDto.initial('task5'),
  ];

  @override
  Future<TodoDto> getTodo(String id) {
    final todoDto = findTodo(id);

    if (todoDto == null) throw DataBaseException();

    return Future.delayed(duration, () => todoDto);
  }

  @override
  Future<List<TodoDto>> getAllTodo() {
    return Future.delayed(duration, () => todos);
  }

  @override
  Future<TodoDto> create(String name) {
    return Future.delayed(duration, () {
      final todoDto = TodoDto.initial(name);

      todos.add(todoDto);
      return todoDto;
    });
  }

  @override
  Future<TodoDto> delete(String id) {
    return Future.delayed(duration, () {
      final todoDto = findTodo(id);

      if (todoDto == null) throw DataBaseException();
      if (todos.remove(todoDto) == false) throw DataBaseException();

      return todoDto;
    });
  }

  @override
  Future<TodoDto> update(TodoDto todo) {
    return Future.delayed(duration, () {
      final id = todo.id;
      final task = todo.task;
      final done = todo.done;
      final index = todos.indexWhere((e) => e.id == id);

      if (index == -1) throw DataBaseException();

      final todoDto = todos[index].copyWith(task: task, done: done);

      todos[index] = todoDto;
      return todoDto;
    });
  }

  TodoDto? findTodo(String id) {
    return todos.firstWhereOrNull((e) => e.id == id);
  }
}
