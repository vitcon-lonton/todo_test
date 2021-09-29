import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo/core/failures.dart';
import 'package:todo/core/value_objects.dart';

import 'value_objects.dart';

part 'todo.freezed.dart';

@freezed
class Todo with _$Todo {
  const Todo._();

  const factory Todo(
      {required UniqueId id,
      required TodoTask task,
      required bool done}) = _TodoItem;

  factory Todo.empty() => Todo(id: UniqueId(), task: TodoTask(''), done: false);

  Option<ValueFailure<dynamic>> get failureOption {
    return task.value.fold((f) => some(f), (_) => none());
  }
}
