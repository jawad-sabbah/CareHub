import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/dashboard_data.dart';

const _brandBlue = Color(0xFF1E3FE0);
const _track = Color(0xFFE3E7F5);
const _muted = Color(0xFF8A90A6);
const _ink = Color(0xFF1A1F36);

/// Coverage-used ring + policy-period progress bar.
/// Hides whichever part it lacks data for, and disappears entirely if it has
/// neither coverage amounts nor policy dates.
class CoverageOverview extends StatelessWidget {
  const CoverageOverview({super.key, required this.data});

  final DashboardData data;

  bool get _hasCoverage =>
      data.annualLimit != null && data.annualLimit! > 0 && data.usedAmount != null;

  bool get _hasPolicyDates =>
      data.insuranceCard != null &&
      DateTime.tryParse(data.insuranceCard!.startDate) != null &&
      DateTime.tryParse(data.insuranceCard!.expiryDate) != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasCoverage && !_hasPolicyDates) return const SizedBox.shrink();

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
          if (_hasCoverage) _coverageRow(),
          if (_hasCoverage && _hasPolicyDates)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: Color(0xFFECEEF5)),
            ),
          if (_hasPolicyDates) _policyPeriod(),
        ],
      ),
    );
  }

  Widget _coverageRow() {
    final used = data.usedAmount!;
    final limit = data.annualLimit!;
    final remaining = (limit - used).clamp(0, limit).toDouble();
    final fraction = (used / limit).clamp(0.0, 1.0);
    final percent = (fraction * 100).round();

    return Row(
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(96, 96),
                painter: _RingPainter(fraction: fraction, color: _brandBlue, track: _track),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$percent%',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _ink)),
                  const Text('used', style: TextStyle(fontSize: 11, color: _muted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Coverage this year', style: TextStyle(fontSize: 12, color: _muted)),
              const SizedBox(height: 8),
              _legendRow(_brandBlue, 'Used', _money(used)),
              const SizedBox(height: 4),
              _legendRow(_track, 'Remaining', _money(remaining)),
              const SizedBox(height: 8),
              Container(height: 0.5, color: const Color(0xFFECEEF5)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Annual limit', style: TextStyle(fontSize: 12, color: _muted)),
                  Text(_money(limit), style: const TextStyle(fontSize: 12, color: _muted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendRow(Color dot, String label, String value) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: dot, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: _muted)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
      ],
    );
  }

  Widget _policyPeriod() {
    final start = DateTime.parse(data.insuranceCard!.startDate);
    final expiry = DateTime.parse(data.insuranceCard!.expiryDate);
    final now = DateTime.now();

    final total = expiry.difference(start).inDays;
    final elapsed = now.difference(start).inDays;
    final fraction = total <= 0 ? 1.0 : (elapsed / total).clamp(0.0, 1.0);
    final daysLeft = expiry.difference(now).inDays;
    final label = daysLeft <= 0 ? 'Expired' : '$daysLeft days left';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Policy period', style: TextStyle(fontSize: 12, color: _muted)),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _brandBlue)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 10,
            backgroundColor: _track,
            valueColor: const AlwaysStoppedAnimation(_brandBlue),
          ),
        ),
      ],
    );
  }

  static String _money(double v) {
    final s = v.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '\$$buf';
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.color, required this.track});

  final double fraction;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, trackPaint);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * fraction.clamp(0.0, 1.0), false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.fraction != fraction || old.color != color || old.track != track;
}