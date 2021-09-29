import 'package:dartz/dartz.dart';
import 'package:todo/core/failures.dart';
import 'package:todo/core/value_objects.dart';
import 'package:todo/core/value_validators.dart';

class TodoTask extends ValueObject<String> {
  static const maxLength = 1000;

  const TodoTask._(this.value);

  factory TodoTask(String input) {
    return TodoTask._(
      validateMaxStringLength(input, maxLength)
          .flatMap(validateStringNotEmpty)
          .flatMap(validateSingleLine),
    );
  }

  @override
  final Either<ValueFailure<String>, String> value;
}
