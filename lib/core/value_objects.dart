import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import 'errors.dart';
import 'failures.dart';
import 'value_validators.dart';

class Email extends ValueObject<String> {
  static const maxLength = 15;

  @override
  final Either<ValueFailure<String>, String> value;

  factory Email(String input) {
    return Email._(validateStringNotEmpty(input).flatMap(validateEmailAddress));
  }

  const Email._(this.value);
}

class Name extends ValueObject<String> {
  static const maxLength = 15;

  @override
  final Either<ValueFailure<String>, String> value;

  factory Name(String input) {
    return Name._(validateStringNotEmpty(input)
        .flatMap(validateSingleLine)
        .flatMap((v) => validateMaxStringLength(input, maxLength)));
  }

  const Name._(this.value);
}

class Password extends ValueObject<String> {
  static const minLength = 8;
  static const maxLength = 15;

  @override
  final Either<ValueFailure<String>, String> value;

  factory Password(String input) {
    return Password._(validateStringNotEmpty(input).flatMap((v) {
      return validateMinStringLength(input, minLength);
    }).flatMap(validatePassword));
  }

  const Password._(this.value);
}

class Phone extends ValueObject<String> {
  static const maxLength = 15;
  static const minLength = 0;

  @override
  final Either<ValueFailure<String>, String> value;

  factory Phone(String input) {
    return Phone._(validateStringNotEmpty(input)
        .flatMap(validateSingleLine)
        .flatMap((v) => validateMinStringLength(input, minLength))
        .flatMap((v) => validateMaxStringLength(input, maxLength))
        .flatMap(validateIsNumeric));
  }

  const Phone._(this.value);
}

class UniqueId extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  factory UniqueId() => UniqueId._(right(const Uuid().v1()));

  factory UniqueId.fromUniqueString(String uniqueId) {
    return UniqueId._(right(uniqueId));
  }

  const UniqueId._(this.value);
}

@immutable
abstract class ValueObject<T> {
  const ValueObject();
  Either<ValueFailure<dynamic>, Unit> get failureOrUnit {
    return value.fold((l) => left(l), (r) => right(unit));
  }

  @override
  int get hashCode => value.hashCode;

  bool get valid => value.isRight();

  Either<ValueFailure<T>, T> get value;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ValueObject<T> && o.value == value;
  }

  /// Throws [UnexpectedValueError] containing the [ValueFailure]
  T getOrCrash() {
    // id = identity - same as writing (right) => right
    return value.fold((f) => throw UnexpectedValueError(f), id);
  }

  @override
  String toString() => 'Value($value)';
}
