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

  /// Converts "YYYY-MM-DD" to "DD-MM-YYYY"
  static String formatDateDMY(String input) {
    if (input.isEmpty) return input;
    final parts = input.split('-'); // [YYYY, MM, DD]
    if (parts.length != 3) return input; // invalid format
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  static String formatDateDMYWithMonth(String input) {
    if (input.isEmpty) return input;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final parts = input.split('-'); // [YYYY, MM, DD]
    if (parts.length != 3) return input; // invalid format

    final day = parts[2];
    final monthIndex = int.tryParse(parts[1]);
    final year = parts[0];

    if (monthIndex == null || monthIndex < 1 || monthIndex > 12) return input;

    final month = months[monthIndex - 1];
    return '$day-$month-$year';
  }

  static String formatTime12Hour(String input, {bool showSeconds = false}) {
    if (input.isEmpty) return input;

    try {
      final parts = input.split(':'); // [HH, mm, ss]
      if (parts.length < 2) return input;

      int hour = int.tryParse(parts[0]) ?? 0;
      final minute = parts[1];
      final second = parts.length > 2 ? parts[2] : '00';

      final isPM = hour >= 12;
      if (hour == 0) {
        hour = 12; // midnight -> 12
      } else if (hour > 12) {
        hour -= 12; // convert 13-23 -> 1-11
      }

      return showSeconds
          ? '$hour:$minute:$second ${isPM ? 'PM' : 'AM'}'
          : '$hour:$minute ${isPM ? 'PM' : 'AM'}';
    } catch (e) {
      return input;
    }
  }
}
