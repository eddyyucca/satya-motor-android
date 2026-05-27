import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,###', 'id_ID');

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _dateTimeFormat =
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'id_ID');
  static final DateFormat _dbDateFormat = DateFormat('yyyy-MM-dd');

  /// Format angka ke Rupiah (e.g., Rp 150.000)
  static String currency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format angka biasa (e.g., 1.500)
  static String number(int value) {
    return _numberFormat.format(value);
  }

  /// Format tanggal (e.g., 27 Mei 2026)
  static String date(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format tanggal dan waktu (e.g., 27 Mei 2026, 14:30)
  static String dateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Format waktu saja (e.g., 14:30)
  static String time(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format tanggal untuk database (e.g., 2026-05-27)
  static String dbDate(DateTime date) {
    return _dbDateFormat.format(date);
  }

  /// Parse tanggal dari database
  static DateTime parseDbDate(String date) {
    return _dbDateFormat.parse(date);
  }

  /// Format persentase (e.g., 70%)
  static String percentage(double value) {
    return '${value.toStringAsFixed(0)}%';
  }

  /// Format singkat untuk angka besar (e.g., 1.5jt)
  static String compactCurrency(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }
}
