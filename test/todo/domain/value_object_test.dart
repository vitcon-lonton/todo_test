import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/core/errors.dart';
import 'package:todo/core/failures.dart';
import 'package:todo/feature/todo/domain/value_objects.dart';

void main() {
  group("Todo Task", () {
    test("Should return valid task when task string valid", () async {
      // act
      const tTaskStr = 'Valid task string';
      final tTask = TodoTask(tTaskStr);

      // assert
      expect(tTask.valid, true);
      expect(tTask.getOrCrash(), isInstanceOf<String>());
      expect(tTask.failureOrUnit.isRight(), true);
    });

    test(
        "Should throw exception, return ValueFailure, invalid when task string empty",
        () async {
      // act
      const tTaskStr = '';
      final tTask = TodoTask(tTaskStr);
      final valid = tTask.valid;
      final crash = tTask.getOrCrash;
      final failure = tTask.failureOrUnit;

      // assert
      expect(tTaskStr, isEmpty);
      expect(valid, false);
      expect(crash, throwsA(isInstanceOf<UnexpectedValueError>()));
      expect(failure, Left(ValueFailure.empty(failedValue: tTaskStr)));
    });

    test(
        "Should throw exception, return ValueFailure, invalid when task string is multiline",
        () async {
      // act
      const tTaskStr =
          'Should throw\n  exception, return ValueFailure, invalid when task string is multiline';
      final tTask = TodoTask(tTaskStr);
      final valid = tTask.valid;
      final crash = tTask.getOrCrash;
      final failure = tTask.failureOrUnit;

      // assert
      expect(valid, false);
      expect(crash, throwsA(isInstanceOf<UnexpectedValueError>()));
      expect(failure, Left(ValueFailure.multiLine(failedValue: tTaskStr)));
    });

    test(
        "Should throw exception, return ValueFailure, invalid when task length > 1000",
        () async {
      // act
      const longStr =
          'Should throw exception, return ValueFailure, invalid when task length > 1000, Should throw exception, return ValueFailure, invalid when task length > 1000. Should throw exception, return ValueFailure, invalid when task length > 1000Should throw exception, return ValueFailure, invalid when task length > 1000, Should throw exception, return ValueFailure, invalid when task length > 1000. Should throw exception, return ValueFailure, invalid when task length > 1000 Should throw exception, return ValueFailure, invalid when task length > 1000, Should throw exception, return ValueFailure, invalid when task length > 1000. Should throw exception, return ValueFailure, invalid when task length > 1000 Should throw exception, return ValueFailure, invalid when task length > 1000, Should throw exception, return ValueFailure, invalid when task length > 1000. Should throw exception, return ValueFailure, invalid when task length > 1000 Should throw exception, return ValueFailure, invalid when task length > 1000, Should throw exception, return ValueFailure, invalid when task length > 1000. Should throw exception, return ValueFailure, invalid when task length > 1000 Should throw exception, return ValueFailure, invalid when task length > 1000, Should throw exception, return ValueFailure, invalid when task length > 1000. Should throw exception, return ValueFailure, invalid when task length > 1000 Should throw exception, return ValueFailure, invalid when task length > 1000, Should throw exception, return ValueFailure, invalid when task length > 1000. Should throw exception, return ValueFailure, invalid when task length > 1000 ';

      final maxLength = TodoTask.maxLength;
      final tTask = TodoTask(longStr);
      final valid = tTask.valid;
      final crash = tTask.getOrCrash;
      final failure = tTask.failureOrUnit;

      // assert

      expect(longStr.length, greaterThan(maxLength));
      expect(valid, false);
      expect(crash, throwsA(isInstanceOf<UnexpectedValueError>()));
      expect(
        failure,
        left(
          ValueFailure.exceedingLength(failedValue: longStr, max: maxLength),
        ),
      );
    });
  });
}
