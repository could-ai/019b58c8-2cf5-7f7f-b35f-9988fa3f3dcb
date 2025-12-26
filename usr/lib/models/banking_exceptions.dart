class InsufficientFundsException implements Exception {
  final String message;
  InsufficientFundsException(this.message);

  @override
  String toString() => message;
}

class InvalidAmountException implements Exception {
  final String message;
  InvalidAmountException(this.message);

  @override
  String toString() => message;
}
