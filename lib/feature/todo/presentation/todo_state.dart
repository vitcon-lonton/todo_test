part of 'todo_cubit.dart';

@freezed
class TodoStatus with _$TodoStatus {
  const factory TodoStatus.idle() = _Idle;
  const factory TodoStatus.busy() = _Busy;
  const factory TodoStatus.failed() = _Failed;
  const factory TodoStatus.complete() = _Complete;
}

@freezed
class TodoState with _$TodoState {
  TodoState._();
  factory TodoState({
    List<Todo>? todos,
    List<UniqueId>? onProcessing,
    TodoFailure? createFailure,
    TodoFailure? deleteFailure,
    TodoFailure? updateFailure,
    required TodoStatus status,
  }) = _HotelState;

  factory TodoState.initial() => TodoState(status: TodoStatus.idle());

  TodoState busy() => copyWith(status: const TodoStatus.busy());

  TodoState idle() => copyWith(status: const TodoStatus.idle());

  TodoState failed() => copyWith(status: const TodoStatus.failed());

  TodoState processing(UniqueId id) {
    final newList = [...onProcessing ?? <UniqueId>[]];

    newList..add(id);

    return copyWith(onProcessing: newList);
  }

  TodoState unProcessing(UniqueId id) {
    final newList = [...onProcessing ?? <UniqueId>[]];

    newList..removeWhere((element) => element == id);

    return copyWith(onProcessing: newList);
  }

  TodoState updateTodos(Todo todo) {
    final newTodos = [...todos ?? <Todo>[]];

    final index = newTodos.indexWhere((element) => element.id == todo.id);

    newTodos[index] = todo;

    return copyWith(todos: newTodos);
  }

  TodoState addTodo(Todo todo) {
    final newTodos = [...todos ?? <Todo>[]];

    newTodos.add(todo);

    return copyWith(todos: newTodos);
  }

  TodoState removeTodo(UniqueId id) {
    final newTodos = [...todos ?? <Todo>[]];
    final index = newTodos.indexWhere((element) => element.id == id);

    newTodos.removeAt(index);

    return copyWith(todos: newTodos);
  }

  bool Function(UniqueId) get containsId {
    return (UniqueId id) => onProcessing?.contains(id) ?? false;
  }
}
