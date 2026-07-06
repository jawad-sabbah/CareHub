import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/insurance_coverage.dart';
import '../../services/insurance_coverage_service.dart';
import '../../core/api_exception.dart';
import '../../core/date_format.dart';
import '../insurance/insurance_history_screen.dart';
import '../insurance/insurance_details_screen.dart';

class CoverageScreen extends StatefulWidget {
  const CoverageScreen({super.key});

  @override
  State<CoverageScreen> createState() => _CoverageScreenState();
}

class _CoverageScreenState extends State<CoverageScreen> {
  InsuranceCoverage? _coverage;
  bool _isLoading = true;
  String? _error;

  static const _benefitIcons = [
    Icons.local_hospital_outlined,
    Icons.medication_outlined,
    Icons.medical_services_outlined,
    Icons.fitness_center_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final coverage = await InsuranceCoverageService.getCoverage();
      setState(() {
        _coverage = coverage;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Coverage', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _policyCard(_coverage!),
                      const SizedBox(height: 16),
                      _statsRow(_coverage!),
                      const SizedBox(height: 28),
                      const Text('Key Benefits', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      if (_coverage!.benefits.isEmpty)
                        const Text('No benefits listed for this plan.', style: TextStyle(color: Colors.grey))
                      else
                        ..._coverage!.benefits.asMap().entries.map(
                          (entry) => _benefitTile(entry.value, _benefitIcons[entry.key % _benefitIcons.length]),
                        ),
                      const SizedBox(height: 16),
                      _historyBanner(context),
                      const SizedBox(height: 16),
                      _needHelpCard(context, _coverage!),
                    ],
                  ),
                ),
    );
  }

  Widget _policyCard(InsuranceCoverage c) {
    final isActive = c.status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3FE0), Color(0xFF1652D6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.greenAccent.shade400, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.black87),
                const SizedBox(width: 4),
                Text(isActive ? 'Active' : c.status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(c.planName.isNotEmpty ? c.planName : 'Insurance Plan',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('POLICY ID: ${c.policyCode}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('VALID UNTIL', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(formatDisplayDate(c.expiryDate), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PRIMARY HOLDER', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(c.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InsuranceDetailsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('View Details', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(InsuranceCoverage c) {
    final usedPercent = c.annualLimit > 0 ? (c.usedAmount / c.annualLimit).clamp(0.0, 1.0) : 0.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFE3E9FF), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.percent, color: Color(0xFF1E3FE0), size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Coverage', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('${c.coveragePercentage}%', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E3FE0))),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: c.coveragePercentage / 100,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE3E9FF),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF1E3FE0)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFFFE9D6), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFE08A2B), size: 18),
                    ),
                    const Spacer(),
                    const Text('Total Cap', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Annual Limit', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text(_formatCurrency(c.annualLimit), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${_formatCurrency(c.usedAmount)} used',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _benefitTile(String benefit, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFFE3E9FF), child: Icon(icon, color: const Color(0xFF1E3FE0), size: 20)),
        title: Text(benefit, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _historyBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFE3E9FF), borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const InsuranceHistoryScreen()),
          );
        },
        child: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.history, color: Color(0xFF1E3FE0))),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('View Insurance History', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Track your previous plans and claims', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Color(0xFF1E3FE0)),
          ],
        ),
      ),
    );
  }

  Widget _needHelpCard(BuildContext context, InsuranceCoverage c) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF1E3FE0), Color(0xFF274B8C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Need Help?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Our support team is available 24/7 for coverage questions.',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final uri = Uri(scheme: 'tel', path: '+18005550123');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              child: const Row(
                children: [
                  Text('Contact Agent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.call, color: Colors.white, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    final s = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return '\$$buffer';
  }
}