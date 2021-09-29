import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo/core/value_objects.dart';
import 'package:todo/feature/todo/domain/todo.dart';
import 'package:todo/feature/todo/domain/todo_failure.dart';
import 'package:todo/feature/todo/domain/value_objects.dart';
import 'package:todo/feature/todo/infrastructure/todo_dtos.dart';
import 'package:todo/feature/todo/infrastructure/todo_repository.dart';
import 'package:todo/feature/todo/presentation/todo_cubit.dart';

class MockTodo extends Mock implements Todo {}

class MockUniqueId extends Mock implements UniqueId {}

class MockTodoTask extends Mock implements TodoTask {}

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late TodoCubit todoCubit;
  late MockTodoRepository mockTodoRepository;
  final List<Todo> mockTodos = [
    TodoDto.initial('task1').toDomain(),
    TodoDto.initial('task2').toDomain(),
    TodoDto.initial('task3').toDomain(),
  ];

  setUp(() {
    mockTodoRepository = MockTodoRepository();
    todoCubit = TodoCubit(mockTodoRepository);
  });

  setUpAll(() {
    registerFallbackValue<Todo>(MockTodo());
    registerFallbackValue<TodoTask>(MockTodoTask());
    registerFallbackValue<UniqueId>(MockUniqueId());
  });

  test("initial state should be contains status idle", () async {
    // assert
    expect(todoCubit.state.status, equals(TodoStatus.idle()));
    expect(todoCubit.state, equals(TodoState.initial()));
  });

  group('getTodosRequested', () {
    final mockState = TodoState.initial();

    blocTest<TodoCubit, TodoState>(
      'emits status busy and todos when successfully',
      build: () {
        when(
          mockTodoRepository.getAll,
        ).thenAnswer((_) async => Right(mockTodos));

        return TodoCubit(mockTodoRepository);
      },
      act: (cubit) => cubit.getTodosRequested(),
      expect: () => [
        mockState.busy(),
        mockState.idle().copyWith(todos: mockTodos),
      ],
      verify: (_) => verify(mockTodoRepository.getAll).called(1),
    );

    blocTest<TodoCubit, TodoState>(
      'emits status busy and status failed when unsuccessfully',
      build: () {
        when(
          mockTodoRepository.getAll,
        ).thenAnswer((_) async => Left(TodoFailure.unexpected()));

        return TodoCubit(mockTodoRepository);
      },
      act: (cubit) => cubit.getTodosRequested(),
      expect: () => [mockState.busy(), mockState.failed()],
      verify: (_) => verify(mockTodoRepository.getAll).called(1),
    );
  });

  group('create todo', () {
    final mockTask = TodoTask('new task');
    final mockTodo = TodoDto.initial('new task').toDomain();
    final mockState = TodoState.initial();

    blocTest<TodoCubit, TodoState>(
      'emits todo status busy and create successfully',
      build: () {
        when(
          () => mockTodoRepository.create(any()),
        ).thenAnswer((_) async => Right(mockTodo));

        return TodoCubit(mockTodoRepository);
      },
      seed: () => mockState,
      act: (cubit) => cubit.created(mockTask),
      expect: () => [mockState.busy(), mockState.addTodo(mockTodo).idle()],
      verify: (_) => verify(() => mockTodoRepository.create(mockTask)),
    );

    blocTest<TodoCubit, TodoState>(
      'emits todo status busy and create unsuccessfully with failure',
      build: () {
        when(
          () => mockTodoRepository.create(any()),
        ).thenAnswer((_) async => Left(TodoFailure.unexpected()));

        return TodoCubit(mockTodoRepository);
      },
      seed: () => mockState,
      act: (cubit) => cubit.created(mockTask),
      expect: () => [
        mockState.busy(),
        mockState.copyWith(createFailure: TodoFailure.unexpected()).idle()
      ],
      verify: (_) => verify(() => mockTodoRepository.create(mockTask)),
    );

    blocTest<TodoCubit, TodoState>(
      'Un emits when create multiple and status is busy',
      seed: () => mockState.busy(),
      build: () => TodoCubit(mockTodoRepository),
      act: (cubit) => cubit
        ..created(mockTask)
        ..created(mockTask)
        ..created(mockTask)
        ..created(mockTask),
      expect: () => [],
    );
  });

  group('mark done', () {
    final mockTodo = mockTodos.first;
    final mockState = TodoState.initial().copyWith(todos: mockTodos);

    blocTest<TodoCubit, TodoState>(
      'emits todo id in process and mark done successfully',
      build: () {
        when(
          () => mockTodoRepository.update(any()),
        ).thenAnswer((_) async => Right(unit));

        return TodoCubit(mockTodoRepository);
      },
      seed: () => mockState,
      act: (cubit) => cubit.markDone(mockTodo),
      expect: () => [
        mockState.processing(mockTodo.id),
        mockState.copyWith(
          onProcessing: [],
        ).updateTodos(mockTodo.copyWith(done: true))
      ],
      verify: (_) => verifyInOrder([
        () => mockTodoRepository.update(mockTodo.copyWith(done: true)),
      ]),
    );

    blocTest<TodoCubit, TodoState>(
      'emits todo id in process and mark done unsuccessfully',
      build: () {
        when(
          () => mockTodoRepository.update(any()),
        ).thenAnswer((_) async => Left(TodoFailure.unexpected()));

        return TodoCubit(mockTodoRepository);
      },
      seed: () => mockState,
      act: (cubit) => cubit.markDone(mockTodo),
      expect: () => [
        mockState.processing(mockTodo.id),
        mockState.copyWith(
          onProcessing: [],
          updateFailure: TodoFailure.unexpected(),
        ),
      ],
      verify: (_) => verifyInOrder([
        () => mockTodoRepository.update(mockTodo.copyWith(done: true)),
      ]),
    );

    blocTest<TodoCubit, TodoState>(
      'Un emits when mark done multiple and todo in process ',
      seed: () => mockState.processing(mockTodo.id),
      build: () => TodoCubit(mockTodoRepository),
      act: (cubit) => cubit
        ..markDone(mockTodo)
        ..markDone(mockTodo)
        ..markDone(mockTodo)
        ..markDone(mockTodo)
        ..markDone(mockTodo)
        ..markDone(mockTodo),
      expect: () => [],
    );
  });

  group('mark undone', () {
    final mockTodo = mockTodos.first;
    final mockState = TodoState.initial().copyWith(todos: mockTodos);

    blocTest<TodoCubit, TodoState>(
      'emits todo id in process and mark undone successfully',
      build: () {
        when(
          () => mockTodoRepository.update(any()),
        ).thenAnswer((_) async => Right(unit));

        return TodoCubit(mockTodoRepository);
      },
      seed: () => mockState,
      act: (cubit) => cubit.markUnDone(mockTodo),
      expect: () => [
        mockState.processing(mockTodo.id),
        mockState.copyWith(
          onProcessing: [],
        ).updateTodos(mockTodo.copyWith(done: false))
      ],
      verify: (_) => verify(
        () => mockTodoRepository.update(mockTodo.copyWith(done: false)),
      ),
    );

    blocTest<TodoCubit, TodoState>(
      'emits todo id in process and mark undone unsuccessfully with failure',
      build: () {
        when(
          () => mockTodoRepository.update(any()),
        ).thenAnswer((_) async => Left(TodoFailure.unexpected()));

        return TodoCubit(mockTodoRepository);
      },
      seed: () => mockState,
      act: (cubit) => cubit.markUnDone(mockTodo),
      expect: () => [
        mockState.processing(mockTodo.id),
        mockState.copyWith(
          onProcessing: [],
          updateFailure: TodoFailure.unexpected(),
        ),
      ],
      verify: (_) => verify(
        () => mockTodoRepository.update(mockTodo.copyWith(done: false)),
      ),
    );

    blocTest<TodoCubit, TodoState>(
      'Un emits when mark undone multiple and todo in process ',
      seed: () => mockState.processing(mockTodo.id),
      build: () => TodoCubit(mockTodoRepository),
      act: (cubit) => cubit
        ..markUnDone(mockTodo)
        ..markUnDone(mockTodo)
        ..markUnDone(mockTodo)
        ..markUnDone(mockTodo)
        ..markUnDone(mockTodo)
        ..markUnDone(mockTodo),
      expect: () => [],
    );
  });

  group('delete todo', () {
    final mockId = mockTodos.first.id;
    final mockState = TodoState.initial().copyWith(todos: mockTodos);

    blocTest<TodoCubit, TodoState>(
      'emits todo id in process and delete successfully',
      build: () {
        when(
          () => mockTodoRepository.delete(any()),
        ).thenAnswer((_) async => Right(unit));

        return TodoCubit(mockTodoRepository);
      },
      seed: () => mockState,
      act: (cubit) => cubit.deleted(mockId),
      expect: () => [
        mockState.processing(mockId),
        mockState.copyWith(onProcessing: []).removeTodo(mockId)
      ],
      verify: (_) => verify(() => mockTodoRepository.delete(mockId)),
    );

    blocTest<TodoCubit, TodoState>(
      'emits todo id in process and delete unsuccessfully with failure',
      build: () {
        when(
          () => mockTodoRepository.delete(any()),
        ).thenAnswer((_) async => Left(TodoFailure.unexpected()));

        return TodoCubit(mockTodoRepository);
      },
      seed: () => mockState,
      act: (cubit) => cubit.deleted(mockId),
      expect: () => [
        mockState.processing(mockId),
        mockState.copyWith(
          onProcessing: [],
          deleteFailure: TodoFailure.unexpected(),
        ),
      ],
      verify: (_) => verify(() => mockTodoRepository.delete(mockId)),
    );

    blocTest<TodoCubit, TodoState>(
      'Un emits when delete multiple and todo in process ',
      seed: () => mockState.processing(mockId),
      build: () => TodoCubit(mockTodoRepository),
      act: (cubit) => cubit
        ..deleted(mockId)
        ..deleted(mockId)
        ..deleted(mockId)
        ..deleted(mockId)
        ..deleted(mockId),
      expect: () => [],
    );
  });

  group('clear failures', () {
    final mockState = TodoState.initial()
        .copyWith(updateFailure: TodoFailure.unexpected())
        .copyWith(createFailure: TodoFailure.unexpected())
        .copyWith(deleteFailure: TodoFailure.unexpected());

    blocTest<TodoCubit, TodoState>(
      'emits state with all failures have been clearing',
      seed: () => mockState,
      build: () => TodoCubit(mockTodoRepository),
      act: (cubit) => cubit.clearFailure(),
      expect: () => [
        mockState
            .copyWith(updateFailure: null)
            .copyWith(createFailure: null)
            .copyWith(deleteFailure: null)
      ],
    );
  });
}
