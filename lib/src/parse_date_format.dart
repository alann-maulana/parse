final ParseDateFormat parseDateFormat = ParseDateFormat._internal();

/// This is the currently used date format. It is precise to the millisecond.
class ParseDateFormat {
  ParseDateFormat._internal();

  /// Deserialize an ISO-8601 full-precision extended format representation
  /// of date string into [DateTime].
  DateTime? parse(String strDate) => DateTime.tryParse(strDate);

  /// Serialize [DateTime] into an ISO-8601 full-precision
  /// extended format representation.
  String format(DateTime datetime) {
    if (!datetime.isUtc) {
      datetime = datetime.toUtc();
    }

    String y = _fourDigits(datetime.year);
    String m = _twoDigits(datetime.month);
    String d = _twoDigits(datetime.day);
    String h = _twoDigits(datetime.hour);
    String min = _twoDigits(datetime.minute);
    String sec = _twoDigits(datetime.second);
    String ms = _threeDigits(datetime.millisecond);

    return "$y-$m-${d}T$h:$min:$sec.${ms}Z";
  }

  static String _fourDigits(int n) {
    int absN = n.abs();
    String sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }

  static String _threeDigits(int n) {
    if (n >= 100) return "$n";
    if (n >= 10) return "0$n";
    return "00$n";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}
