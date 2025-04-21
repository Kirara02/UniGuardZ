sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success;
  const factory Result.failed(String message, {int? code}) = Failed;

  bool get isSuccess => this is Success<T>;
  bool get isFailed => this is Failed<T>;

  T? get resultValue => isSuccess ? (this as Success<T>).value : null;
  String? get errorMessage => isFailed ? (this as Failed<T>).message : null;
  int? get errorCode => isFailed ? (this as Failed<T>).code : null;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failed<T> extends Result<T> {
  final String message;
  final int? code;
  const Failed(this.message, {this.code});
}
