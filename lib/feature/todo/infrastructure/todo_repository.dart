import 'package:dartz/dartz.dart';
import 'package:todo/core/value_objects.dart';
import 'package:todo/feature/todo/domain/i_todo_repository.dart';
import 'package:todo/feature/todo/domain/todo_failure.dart';
import 'package:todo/feature/todo/domain/todo.dart';
import 'package:todo/feature/todo/domain/value_objects.dart';

import 'todo_dtos.dart';
import 'todo_local_data_source.dart';

class TodoRepository implements ITodoRepository {
  final TodoLocalDataSource _dataSource;

  TodoRepository(this._dataSource);

  @override
  Future<Either<TodoFailure, List<Todo>>> getAll() async {
    try {
      final res = await _dataSource.getAllTodo();

      return Right(res.map((e) => e.toDomain()).toList());
    } catch (e) {
      _logError('GET TODOS', e);
      return Left(const TodoFailure.unexpected());
    }
  }

  @override
  Future<Either<TodoFailure, Todo>> create(TodoTask task) async {
    try {
      final todoName = task.getOrCrash();

      final todo = await _dataSource.create(todoName);

      return right(todo.toDomain());
    } catch (e) {
      _logError('CREATE TODO', e);
      return left(const TodoFailure.unexpected());
    }
  }

  @override
  Future<Either<TodoFailure, Unit>> update(Todo todo) async {
    bool isValid = todo.failureOption.fold(() => true, (f) => false);

    if (!isValid) return left(const TodoFailure.unexpected());

    try {
      final todoDto = TodoDto.fromDomain(todo);

      await _dataSource.update(todoDto);

      return right(unit);
    } catch (e) {
      _logError('UPDATE TODO', e);
      return left(const TodoFailure.unexpected());
    }
  }

  @override
  Future<Either<TodoFailure, Unit>> delete(UniqueId id) async {
    try {
      final noteId = id.getOrCrash();

      await _dataSource.delete(noteId);

      return right(unit);
    } catch (e) {
      _logError('DELETE TODO', e);
      return left(const TodoFailure.unexpected());
    }
  }

  _logError(String tag, error) {
    print("\n");
    print("---------------------EXCEPTION $tag---------------------");
    print("$error");
    print("---------------------EXCEPTION $tag---------------------");
    print("\n");
  }
}
