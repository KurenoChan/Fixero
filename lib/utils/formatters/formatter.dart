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
}
