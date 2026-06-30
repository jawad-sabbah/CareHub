/// Formats an ISO date string from the backend (e.g. "2025-12-31T22:00:00.000Z")
/// into a readable display format (e.g. "Dec 31, 2025").
///
/// Returns the original string unchanged if it can't be parsed, so a
/// malformed date never crashes the UI - it just looks unformatted.
String formatDisplayDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '-';

  DateTime date;
  try {
    date = DateTime.parse(isoDate);
  } catch (_) {
    return isoDate; // fall back to raw string rather than crash
  }

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}