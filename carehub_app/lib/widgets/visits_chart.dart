import 'package:flutter/material.dart';
import '../../../models/dashboard_data.dart';

const _brandBlue = Color(0xFF1E3FE0);
const _brandBlueSoft = Color(0xFF8FA8F0);
const _muted = Color(0xFF8A90A6);
const _ink = Color(0xFF1A1F36);

/// Simple monthly-visits bar chart. Dependency-free: bars are sized with
/// [FractionallySizedBox] against the tallest month.
class VisitsChart extends StatelessWidget {
  const VisitsChart({super.key, required this.months});

  final List<MonthlyVisit> months;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Visits (last 6 months)', style: TextStyle(fontSize: 12, color: _muted)),
          const SizedBox(height: 14),
          if (months.isEmpty || months.every((m) => m.count == 0))
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No visits recorded yet.', style: TextStyle(color: _muted)),
            )
          else
            _bars(),
        ],
      ),
    );
  }

  Widget _bars() {
    final maxCount = months.map((m) => m.count).reduce((a, b) => a > b ? a : b);
    final peak = months.indexWhere((m) => m.count == maxCount);

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < months.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${months[i].count}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _ink)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: maxCount == 0
                              ? 0.04
                              : (months[i].count / maxCount).clamp(0.04, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: i == peak ? _brandBlue : _brandBlueSoft,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(months[i].label, style: const TextStyle(fontSize: 10, color: _muted)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}