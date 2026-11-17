import 'package:intl/intl.dart';

/// All money in PehlaPaisa is stored as whole rupees (`int`).
///
/// Small-income budgets never need paise, and integers avoid floating point
/// drift when we split, round and sum allocations.
final NumberFormat _rupeeFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

final NumberFormat _plainFormat = NumberFormat.decimalPattern('en_IN');

/// Formats [amount] in Indian grouping, e.g. `100000` → `₹1,00,000`.
String formatRupees(num amount) => _rupeeFormat.format(amount);

/// Indian grouping without the currency symbol, e.g. `1,00,000`.
String formatPlain(num amount) => _plainFormat.format(amount);

/// Rounds [value] to the nearest ₹10 (halves round up, e.g. 15 → 20).
int roundTo10(num value) => ((value / 10).round()) * 10;

/// Formats a ratio (0..1) as a whole percentage string without the sign.
int percentOf(num part, num whole) {
  if (whole == 0) return 0;
  return ((part / whole) * 100).round();
}
