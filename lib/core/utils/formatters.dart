import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _rupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _date = DateFormat('d MMMM y', 'en');

  static String rupiah(num value) => _rupiah.format(value);
  static String date(DateTime value) => _date.format(value);
}
