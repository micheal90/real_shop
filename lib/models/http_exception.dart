class HttpExceptionApp implements Exception {
  final String message;

  HttpExceptionApp(this.message);

  @override
  String toString() {
    return message;
  }
}
