import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo/core/value_objects.dart';
import 'package:todo/feature/todo/domain/todo.dart';
import 'package:todo/feature/todo/infrastructure/todo_dtos.dart';
import 'package:todo/feature/todo/presentation/todo_cubit.dart';

class MockTodo extends Mock implements Todo {}

void main() {
  late UniqueId id;
  late UniqueId id2;
  late Todo mockTodo;
  late List<Todo> mockTodos;
  late TodoState mockState;

  setUp(() {
    id = UniqueId();
    id2 = UniqueId();
    mockTodos = [
      TodoDto.initial('task1').toDomain(),
      TodoDto.initial('task2').toDomain(),
      TodoDto.initial('task3').toDomain()
    ];
    mockTodo = mockTodos.first;
    mockState = TodoState.initial().copyWith(todos: mockTodos);
  });

  group('initial', () {
    test('has correct status', () {
      final state = TodoState.initial();

      expect(state.todos, null);
      expect(state.onProcessing, null);
      expect(state.createFailure, null);
      expect(state.deleteFailure, null);
      expect(state.updateFailure, null);
      expect(state.status, TodoStatus.idle());
    });
  });

  group('busy', () {
    test('has correct status', () {
      final state = TodoState.initial().busy();

      expect(state.status, TodoStatus.busy());
    });
  });

  group('failed', () {
    test('has correct status', () {
      final state = TodoState.initial().failed();

      expect(state.status, TodoStatus.failed());
    });
  });

  group('idle', () {
    test('has correct status', () {
      final state = TodoState.initial().idle();

      expect(state.status, TodoStatus.idle());
    });
  });

  group('processing', () {
    test('has contains id', () {
      final newState = mockState.processing(id).processing(id2);
      //expect
      expect(newState.containsId(id), true);
      expect(newState.onProcessing, contains(id));
    });
  });

  group('UnProcessing', () {
    test('should un processing contains id', () {
      final newState = mockState.unProcessing(id);

      //expect
      expect(newState.containsId(id), false);
      expect(newState.onProcessing, isNot(contains(id)));
    });
  });

  group('update Todo', () {
    test('should update todo', () {
      //expect
      expect(mockState.updateTodos(mockTodo).todos?.first, mockTodo);
    });
  });

  group('add Todo', () {
    test('should add todo', () {
      final newTodo = TodoDto.initial('new').toDomain();
      //expect
      expect(mockState.addTodo(newTodo).todos?.last, newTodo);
    });
  });

  group('remove Todo', () {
    test('should remove todo', () {
      //expect
      expect(mockState.removeTodo(mockTodo.id).todos?.first, isNot(mockTodo));
    });
  });
}
