class Formatter {
  static String capitalize(String input) {
    return input
        .toLowerCase() // convert entire string to lowercase first
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  static String todayDate() {
    final now = DateTime.now();
    return now.toIso8601String().split("T").first; // "2025-09-16"
  }

  static String todayTime() {
    final now = DateTime.now();
    return now.toIso8601String().split("T").last.split(".").first; // "14:32:05"
  }

  static String today() {
    final now = DateTime.now();
    return now.toIso8601String(); // full datetime "2025-09-16T14:32:05.123Z"
  }
}
