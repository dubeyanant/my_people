/// Shared date formatting utilities.
abstract final class DateHelper {
  static const _monthNames = [
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

  /// Returns the abbreviated month name for [month] (1-indexed).
  /// Returns an empty string for out-of-range values.
  static String monthName(int month) {
    if (month >= 1 && month <= 12) return _monthNames[month - 1];
    return '';
  }

  /// Formats [date] as `"D Mon"` or `"D Mon, YYYY"` when the year differs
  /// from the current year.
  static String formatBirthday(DateTime date) {
    final year = date.year != DateTime.now().year ? ', ${date.year}' : '';
    return '${date.day} ${monthName(date.month)}$year';
  }
}
