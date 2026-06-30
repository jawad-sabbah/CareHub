import 'package:flutter/material.dart';
import '../../models/insurance_details.dart';
import '../../services/insurance_details_service.dart';
import '../../core/api_exception.dart';
import '../../core/date_format.dart';

class InsuranceDetailsScreen extends StatefulWidget {
  const InsuranceDetailsScreen({super.key});

  @override
  State<InsuranceDetailsScreen> createState() => _InsuranceDetailsScreenState();
}

class _InsuranceDetailsScreenState extends State<InsuranceDetailsScreen> {
  InsuranceDetails? _details;
  bool _isLoading = true;
  String? _error;

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
      final details = await InsuranceDetailsService.getDetails();
      setState(() {
        _details = details;
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
        title: const Text('Insurance Details', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3FE0)),
          onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : null,
        ),
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
                      _memberCard(_details!),
                      const SizedBox(height: 18),
                      _policyOverviewCard(_details!),
                      const SizedBox(height: 18),
                      _planBenefitsCard(_details!),
                      const SizedBox(height: 18),
                      _networkInfoCard(_details!),
                    ],
                  ),
                ),
    );
  }

  Widget _memberCard(InsuranceDetails d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3FE0), Color(0xFF15296B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              if (d.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Primary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _memberField('MEMBER NAME', d.userName),
          const SizedBox(height: 14),
          _memberField('POLICY CODE', d.policyCode),
          const SizedBox(height: 14),
          _memberField('PLAN NAME', d.planName),
        ],
      ),
    );
  }

  Widget _memberField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value.isNotEmpty ? value : '-', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _policyOverviewCard(InsuranceDetails d) {
    final isActive = d.status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Policy Overview', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('Provider: ${d.providerName}', style: const TextStyle(color: Colors.grey, height: 1.3)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: isActive ? Colors.green.shade100 : Colors.red.shade100, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: isActive ? Colors.green.shade700 : Colors.red.shade700),
                    const SizedBox(width: 4),
                    Text(isActive ? 'Active' : d.status,
                        style: TextStyle(color: isActive ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          _overviewRow(Icons.description_outlined, 'Policy Code', d.policyCode),
          const SizedBox(height: 18),
          _overviewRow(
            Icons.calendar_today_outlined,
            'Coverage Period',
            '${formatDisplayDate(d.startDate)} - ${formatDisplayDate(d.expiryDate)}',
            subtext: 'Starts ${formatDisplayDate(d.startDate)} • Expires ${formatDisplayDate(d.expiryDate)}',
          ),
          const SizedBox(height: 18),
          _overviewRow(Icons.info_outline, 'Plan Description', d.description.isNotEmpty ? d.description : 'No description available.'),
        ],
      ),
    );
  }

  Widget _overviewRow(IconData icon, String label, String value, {String? subtext}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFE3E9FF), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF1E3FE0), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, height: 1.3)),
              if (subtext != null) ...[
                const SizedBox(height: 2),
                Text(subtext, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _planBenefitsCard(InsuranceDetails d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plan Benefits', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Annual Limit', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(_formatCurrency(d.annualLimit), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3FE0))),
                      Text('Per year', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Coverage', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${d.coveragePercentage}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('In-Network', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // "Included Services" intentionally omitted - no backend data
          // exists for a per-plan service category list yet.
        ],
      ),
    );
  }

  Widget _networkInfoCard(InsuranceDetails d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
        borderRadius: BorderRadius.circular(14),
        border: const Border(left: BorderSide(color: Color(0xFF1E3FE0), width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF1E3FE0), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Provider Network Information', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(color: Colors.black87, height: 1.4),
                    children: [
                      const TextSpan(text: 'Your coverage is active under '),
                      TextSpan(text: d.providerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '. Confirm your provider is in this network to receive the full ${d.coveragePercentage}% coverage benefit.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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