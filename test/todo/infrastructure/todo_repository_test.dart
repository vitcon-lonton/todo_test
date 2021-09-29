import 'package:dartz/dartz.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo/core/exceptions.dart';
import 'package:todo/feature/todo/domain/todo.dart';
import 'package:todo/feature/todo/domain/todo_failure.dart';
import 'package:todo/feature/todo/domain/value_objects.dart';
import 'package:todo/feature/todo/infrastructure/todo_dtos.dart';
import 'package:todo/feature/todo/infrastructure/todo_local_data_source.dart';
import 'package:todo/feature/todo/infrastructure/todo_repository.dart';

class MockTodoDto extends Mock implements TodoDto {}

class MockTodoLocalDataSource extends Mock implements TodoLocalDataSource {}

void main() {
  late TodoDto tTodoDto;
  late TodoTask tTodoTask;
  late TodoTask tInvalidTask;

  late TodoRepository todoRepository;
  late MockTodoLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue<TodoDto>(MockTodoDto());
  });

  setUp(() {
    tInvalidTask = TodoTask('');
    tTodoTask = TodoTask('New Task');
    tTodoDto = TodoDto.initial(tTodoTask.getOrCrash());
    mockLocalDataSource = MockTodoLocalDataSource();
    todoRepository = TodoRepository(mockLocalDataSource);
  });

  group("getAllTodo", () {
    final tTodosDto = [
      TodoDto.initial('Reading cached asset graph.'),
      TodoDto.initial('task2'),
      TodoDto.initial('task3'),
      TodoDto.initial('task4'),
      TodoDto.initial('task5'),
    ];

    test("Should return list of todo when call to local database is successful",
        () async {
      // arrange
      when(() => mockLocalDataSource.getAllTodo())
          .thenAnswer((_) async => tTodosDto);

      // act
      final result = await todoRepository.getAll();

      // assert
      expect(result.isRight(), true);
      expect(result | [], isA<List<Todo>>());
    });

    test("Should return Todo failure when call to database is unsuccessful",
        () async {
      // arrange
      when(() => mockLocalDataSource.getAllTodo())
          .thenThrow(DataBaseException());

      // act
      final result = await todoRepository.getAll();

      // assert
      verify(() => mockLocalDataSource.getAllTodo());
      expect(result.isLeft(), true);
      expect(result, Left(TodoFailure.unexpected()));
    });
  });

  group("addTodo", () {
    test(
        "Should return new added todo when call to local database is successful",
        () async {
      // arrange
      when(() => mockLocalDataSource.create(any()))
          .thenAnswer((_) async => tTodoDto);

      // act
      final result = await todoRepository.create(tTodoTask);

      // assert
      expect(result.isRight(), true);
      expect(result, Right(tTodoDto.toDomain()));
    });

    test(
        "Should return Todo Failure unexpected when call to database is unsuccessful",
        () async {
      // arrange
      when(() => mockLocalDataSource.create(any()))
          .thenThrow(DataBaseException());

      // act
      final result = await todoRepository.create(tTodoTask);

      // assert
      verify(() => mockLocalDataSource.create(tTodoTask.getOrCrash()));
      expect(result.isLeft(), true);
      expect(result, Left(TodoFailure.unexpected()));
    });

    test("Should return Todo Failure when pass invalid task", () async {
      // act
      final result = await todoRepository.create(tInvalidTask);

      // assert
      expect(result, Left(TodoFailure.unexpected()));
    });
  });

  group("updateTodo", () {
    test("Should return added todo when call to local database is successful",
        () async {
      // arrange
      when(() => mockLocalDataSource.update(any()))
          .thenAnswer((_) async => tTodoDto);

      // act
      final tTodo = tTodoDto.toDomain();
      final result = await todoRepository.update(tTodo);

      // assert
      verify(() => mockLocalDataSource.update(tTodoDto));
      expect(result.isRight(), true);
      expect(result, Right(unit));
    });

    test(
        "Should return Todo Failure unexpected when call to database is unsuccessful",
        () async {
      // arrange
      when(() => mockLocalDataSource.update(any()))
          .thenThrow(DataBaseException());

      // act
      final tTodo = tTodoDto.toDomain();
      final result = await todoRepository.update(tTodo);

      // assert
      verify(() => mockLocalDataSource.update(tTodoDto));
      expect(result.isLeft(), true);
      expect(result, Left(TodoFailure.unexpected()));
    });

    test("Should return Todo Failure when pass invalid todo", () async {
      // act
      final tTodo = tTodoDto.toDomain().copyWith(task: tInvalidTask);
      final result = await todoRepository.update(tTodo);

      // assert
      expect(result.isLeft(), true);
      expect(result, Left(TodoFailure.unexpected()));
    });
  });
}
