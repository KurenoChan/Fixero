import 'dart:math';

class IDGenerator {
  static final Random _random = Random();

  /// Generates an alphanumeric string of given [length] (A–Z, 0–9).
  static String _generateAlphanumeric(int length) {
    return List.generate(length, (_) {
      if (_random.nextBool()) {
        // A–Z (ASCII 65–90)
        return String.fromCharCode(65 + _random.nextInt(26));
      } else {
        // 0–9
        return _random.nextInt(10).toString();
      }
    }).join();
  }

  /// Generates a numeric string of given [length], zero-padded.
  static String _generateNumber(int length) {
    int max = pow(10, length).toInt();
    return _random.nextInt(max).toString().padLeft(length, '0');
  }

  // ==========================
  // Flexible ID generators
  // ==========================

  /// Item IDs → ITM-A1B2C3-0042
  static String generateItemID() {
    String randomPart = _generateAlphanumeric(6);
    String numberPart = _generateNumber(4);
    return "ITM-$randomPart-$numberPart";
  }
}
