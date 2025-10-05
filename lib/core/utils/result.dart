class Result<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  Result.success(this.data) : isSuccess = true, error = null;

  Result.failure(this.error) : isSuccess = false, data = null;
}
