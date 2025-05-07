import 'package:ios_chipher_app/core/errors/failures.dart';

/// Класс для обработки результатов операций с возможностью успеха или ошибки
class Result<T> {
  final T? _value;
  final Failure? _failure;

  const Result._({T? value, Failure? failure})
    : _value = value,
      _failure = failure;

  /// Создает успешный результат
  factory Result.success(T value) => Result._(value: value);

  /// Создает результат с ошибкой
  factory Result.failure(Failure failure) => Result._(failure: failure);

  /// Проверяет, успешен ли результат
  bool get isSuccess => _failure == null;

  /// Проверяет, содержит ли результат ошибку
  bool get isFailure => _failure != null;

  /// Возвращает значение или выбрасывает исключение, если результат содержит ошибку
  T get value {
    if (_failure != null) {
      throw StateError(
        'Невозможно получить значение из Result с ошибкой: ${_failure.message}',
      );
    }
    return _value as T;
  }

  /// Возвращает ошибку или выбрасывает исключение, если результат успешен
  Failure get failure {
    if (_failure == null) {
      throw StateError('Невозможно получить ошибку из успешного Result');
    }
    return _failure;
  }

  /// Выполняет одно из двух действий в зависимости от результата
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(value);
    } else {
      return onFailure(failure);
    }
  }

  /// Преобразует значение, если результат успешен
  Result<R> map<R>(R Function(T value) transform) {
    if (isSuccess) {
      return Result.success(transform(value));
    } else {
      return Result.failure(failure);
    }
  }
}
