class ResultUtils<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ResultUtils.success(this.data) : isSuccess = true, error = null;

  ResultUtils.failure(this.error) : isSuccess = false, data = null;
}
