import 'package:uuid/uuid.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:todo/core/value_objects.dart';
import 'package:todo/feature/todo/domain/todo.dart';
import 'package:todo/feature/todo/domain/value_objects.dart';

part 'todo_dtos.freezed.dart';
part 'todo_dtos.g.dart';

@freezed
class TodoDto with _$TodoDto {
  const TodoDto._();

  const factory TodoDto({
    required String id,
    required String task,
    required bool done,
  }) = _TodoDto;

  factory TodoDto.initial(String name) {
    return TodoDto(id: Uuid().v1(), task: name, done: false);
  }

  factory TodoDto.fromDomain(Todo todoItem) {
    return TodoDto(
      id: todoItem.id.getOrCrash(),
      task: todoItem.task.getOrCrash(),
      done: todoItem.done,
    );
  }

  Todo toDomain() {
    return Todo(
      id: UniqueId.fromUniqueString(id),
      task: TodoTask(task),
      done: done,
    );
  }

  factory TodoDto.fromJson(Map<String, dynamic> json) =>
      _$TodoDtoFromJson(json);
}
