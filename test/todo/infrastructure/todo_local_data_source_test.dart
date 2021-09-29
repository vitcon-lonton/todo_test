import 'package:flutter_test/flutter_test.dart';
import 'package:todo/core/exceptions.dart';
import 'package:todo/feature/todo/infrastructure/todo_dtos.dart';
import 'package:todo/feature/todo/infrastructure/todo_local_data_source.dart';

void main() {
  late TodoLocalDataSource todoLocalDataSource;

  setUp(() {
    todoLocalDataSource = TodoLocalDataSource();
  });

  group("getTodo", () {
    test("should return todo when there exists with the given id", () async {
      final todoDto = todoLocalDataSource.todos.first;
      final tId = todoDto.id;
      // act
      final result = await todoLocalDataSource.getTodo(tId);
      // assert
      expect(result, todoDto);
    });

    test(
        "should throw DataBaseException when there is no todo exists with the given id",
        () async {
      const tId = '1&3900000';
      // act
      final call = todoLocalDataSource.getTodo;
      // assert
      expect(() => call(tId), throwsA(isInstanceOf<DataBaseException>()));
    });
  });

  group("getAllTodo", () {
    test("should return list of sll todo from local in memory data source",
        () async {
      final todos = todoLocalDataSource.todos;
      // act
      final result = await todoLocalDataSource.getAllTodo();
      // assert
      expect(result, todos);
    });
  });

  group("addTodo", () {
    test("should add a todo and return it from local in memory data source",
        () async {
      const tTask = "test";
      // act
      final todo = await todoLocalDataSource.create(tTask);
      // assert
      expect(todo, isInstanceOf<TodoDto>());
    });
  });

  group("deleteTodo", () {
    test("should delete todo when there exists with the given id", () async {
      final todo = todoLocalDataSource.todos.first;
      // act
      final call = todoLocalDataSource.delete;
      // assert
      expect(todo, await call(todo.id));
    });

    test(
        "should throw DataBaseException when there is no todo exists with the given id",
        () async {
      const tId = '1&3900000';
      // act
      final call = todoLocalDataSource.delete;
      // assert
      expect(() => call(tId), throwsA(isInstanceOf<DataBaseException>()));
    });
  });

  group("updateTodo", () {
    test("should update todo when there exists with the given id", () async {
      final todo = todoLocalDataSource.todos.first;
      final newTodo = todo.copyWith(done: !todo.done);
      // act
      final call = todoLocalDataSource.update;
      // assert
      expect(newTodo, await call(newTodo));
    });

    test(
        "should throw DataBaseException when there is no todo exists with the given id",
        () async {
      final tTodo = TodoDto.initial('test');
      // act
      final call = todoLocalDataSource.update;
      // assert
      expect(() => call(tTodo), throwsA(isInstanceOf<DataBaseException>()));
    });
  });
}
