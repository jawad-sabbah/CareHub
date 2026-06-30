import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/dashboard_data.dart';
import '../../services/dashboard_service.dart';
import '../../services/session.dart';
import '../../core/api_exception.dart';
import '../../core/date_format.dart';
import '../family/family_list_screen.dart';
import '../family/add_family_member_screen.dart';
import '../centers/medical_centers_list_screen.dart';
import '../insurance/insurance_history_screen.dart';
import '../insurance/insurance_details_screen.dart';
import '../medical_records/medical_records_list_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DashboardData? _data;
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
      final data = await DashboardService.getDashboard();
      setState(() {
        _data = data;
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final data = _data!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _greetingBar(data.username),
              const SizedBox(height: 20),
              if (data.insuranceCard != null) _insuranceCard(data.insuranceCard!)
              else _noInsuranceCard(),
              const SizedBox(height: 28),
              const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _quickActionsGrid(context),
              const SizedBox(height: 28),
              const Text('Recent Medical Records', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (data.recentMedicalRecords.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No medical records yet.', style: TextStyle(color: Colors.grey)),
                )
              else
                ...data.recentMedicalRecords.map(_recordTile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _greetingBar(String username) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFF1E3FE0),
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Hello, $username',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3FE0))),
        ),
        const Icon(Icons.notifications_outlined, color: Color(0xFF1E3FE0)),
      ],
    );
  }

  Widget _insuranceCard(InsuranceCard card) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3FE0), Color(0xFF1652D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Provider Name', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(card.providerName.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Status', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(card.status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _cardField('Policy Code', card.policyCode)),
              Expanded(child: _cardField('Insurance Plan', card.planName)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
          children: [
            Expanded(child: _cardField('Effective Date', formatDisplayDate(card.startDate))),
            Expanded(child: _cardField('Expiry Date', formatDisplayDate(card.expiryDate))),
          ],
        ),
          const SizedBox(height: 20),
          if (card.qrCodeBase64 != null) _qrCode(card.qrCodeBase64!),
        ],
      ),
    );
  }

  Widget _cardField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _qrCode(String dataUri) {
    // dataUri looks like "data:image/png;base64,iVBORw0KG..."
    // Strip everything before the comma to get the raw base64 string.
    final base64Str = dataUri.contains(',') ? dataUri.split(',').last : dataUri;
    Uint8List? bytes;
    try {
      bytes = base64Decode(base64Str);
    } catch (_) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Image.memory(bytes, width: 140, height: 140),
      ),
    );
  }

  Widget _noInsuranceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
      child: const Text('No active insurance policy found.'),
    );
  }

  Widget _quickActionsGrid(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction('Medical History', Icons.history, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MedicalRecordsListScreen()),
        ); 
      }),
      _QuickAction('Insurance Details', Icons.description_outlined, () {
        Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const InsuranceDetailsScreen()),
      );
      }),
      _QuickAction('Medical Centers', Icons.add_box_outlined, () {
         Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MedicalCentersListScreen()),
        );
      }),
      _QuickAction('Insurance History', Icons.receipt_long_outlined, () {
         Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const InsuranceHistoryScreen()),
        );
      }),
      // Owner-only: only policy owners can invite new family members.
      if (Session.isPrimary)
      ...[
        _QuickAction('Add Family Member', Icons.person_add_alt_1_outlined, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddFamilyMemberScreen()),
          );
        }),
        _QuickAction('Family Members', Icons.groups_outlined, () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FamilyListScreen()),
          );
        }),
      ],
      // Visible to both roles - viewing the family list is fine for everyone.
     
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.3,
      children: actions.map((a) => _quickActionCard(a)).toList(),
    );
  }

  Widget _quickActionCard(_QuickAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE8EAF6),
              radius: 22,
              child: Icon(action.icon, color: const Color(0xFF1E3FE0)),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(action.label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordTile(RecentMedicalRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.local_hospital_outlined, color: Color(0xFF1E3FE0))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${record.medicalCenter} • ${formatDisplayDate(record.visitDate)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _QuickAction(this.label, this.icon, this.onTap);
}