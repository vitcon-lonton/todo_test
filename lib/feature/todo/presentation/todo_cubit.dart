import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo/core/value_objects.dart';
import 'package:todo/feature/todo/domain/todo.dart';
import 'package:todo/feature/todo/domain/todo_failure.dart';
import 'package:todo/feature/todo/domain/value_objects.dart';
import 'package:todo/feature/todo/infrastructure/todo_repository.dart';

part 'todo_cubit.freezed.dart';
part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository _todoRepository;

  TodoCubit(this._todoRepository) : super(TodoState.initial());

  Future<void> created(TodoTask task) async {
    final busy = state.status.maybeMap(orElse: () => false, busy: (_) => true);

    if (busy) return;

    Either<TodoFailure, Todo>? failureOrSuccess;

    emit(state.busy());

    failureOrSuccess = await _todoRepository.create(task);

    failureOrSuccess.fold(
      (failure) => emit(state.copyWith(createFailure: failure).idle()),
      (todo) => emit(state.addTodo(todo).idle()),
    );
  }

  Future<void> deleted(UniqueId id) async {
    bool idOnProcessing = state.containsId(id);

    if (idOnProcessing) return;

    Either<TodoFailure, Unit>? failureOrSuccess;

    emit(state.processing(id));

    failureOrSuccess = await _todoRepository.delete(id);

    failureOrSuccess.fold(
      (failure) => emit(
        state.copyWith(deleteFailure: failure).unProcessing(id),
      ),
      (success) => emit(state.removeTodo(id).unProcessing(id)),
    );
  }

  Future<void> markDone(Todo todo) async {
    bool idOnProcessing = state.containsId(todo.id);

    if (idOnProcessing) return;

    Either<TodoFailure, Unit>? failureOrSuccess;

    emit(state.processing(todo.id));

    final newTodo = todo.copyWith(done: true);

    failureOrSuccess = await _todoRepository.update(newTodo);

    failureOrSuccess.fold(
      (failure) => emit(
        state.copyWith(updateFailure: failure).unProcessing(todo.id),
      ),
      (success) => emit(state.updateTodos(newTodo).unProcessing(newTodo.id)),
    );
  }

  Future<void> markUnDone(Todo todo) async {
    bool idOnProcessing = state.containsId(todo.id);

    if (idOnProcessing) return;

    Either<TodoFailure, Unit>? failureOrSuccess;

    emit(state.processing(todo.id));

    final newTodo = todo.copyWith(done: false);

    failureOrSuccess = await _todoRepository.update(newTodo);

    failureOrSuccess.fold(
      (failure) => emit(
        state.copyWith(updateFailure: failure).unProcessing(todo.id),
      ),
      (success) => emit(state.updateTodos(newTodo).unProcessing(newTodo.id)),
    );
  }

  Future<void> getTodosRequested() async {
    Either<TodoFailure, List<Todo>>? failureOrSuccess;

    emit(state.copyWith(todos: null).busy());

    failureOrSuccess = await _todoRepository.getAll();

    failureOrSuccess.fold(
      (failure) => emit(state.failed()),
      (todos) => emit(state.copyWith(todos: todos).idle()),
    );
  }

  void clearFailure() {
    emit(state
        .copyWith(updateFailure: null)
        .copyWith(createFailure: null)
        .copyWith(deleteFailure: null));
  }
}
