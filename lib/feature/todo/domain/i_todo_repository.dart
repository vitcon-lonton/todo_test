import 'package:dartz/dartz.dart';

import 'package:todo/core/value_objects.dart';

import 'todo.dart';
import 'todo_failure.dart';
import 'value_objects.dart';

abstract class ITodoRepository {
  Future<Either<TodoFailure, List<Todo>>> getAll();
  Future<Either<TodoFailure, Unit>> delete(UniqueId id);
  Future<Either<TodoFailure, Unit>> update(Todo todo);
  Future<Either<TodoFailure, Todo>> create(TodoTask task);
}
