import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/medical_center.dart';
import '../../services/medical_center_service.dart';
import '../../core/api_exception.dart';

class MedicalCenterDetailScreen extends StatefulWidget {
  final int centerId;
  const MedicalCenterDetailScreen({super.key, required this.centerId});

  @override
  State<MedicalCenterDetailScreen> createState() => _MedicalCenterDetailScreenState();
}

class _MedicalCenterDetailScreenState extends State<MedicalCenterDetailScreen> {
  MedicalCenterDetail? _center;
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
      final center = await MedicalCenterService.getById(widget.centerId);
      setState(() {
        _center = center;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _callNow(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the phone dialer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: Text(_center?.name ?? 'Medical Center', style: const TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF1E3FE0)),
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
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          if (_center!.imageUrl != null && _center!.imageUrl!.isNotEmpty)
                            Image.network(
                              _center!.imageUrl!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imagePlaceholder(),
                            )
                          else
                            _imagePlaceholder(),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _center!.isOpen ? Colors.black87 : Colors.red.shade700,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_center!.isOpen ? Icons.check_circle : Icons.cancel, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(_center!.isOpen ? 'Open Now' : 'Closed', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('About the Facility', style: TextStyle(color: Color(0xFF1E3FE0), fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(
                            _center!.description.isNotEmpty ? _center!.description : 'No description available.',
                            style: const TextStyle(height: 1.4),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFE3E9FF), borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_box_outlined, size: 16, color: Color(0xFF1E3FE0)),
                                const SizedBox(width: 6),
                                Text(_typeLabel(_center!.type), style: const TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // "Services Provided" intentionally omitted - no backend
                    // data exists for per-center services/specialties yet.
                    const SizedBox(height: 24),
                    const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: const Color(0xFFEFF3FF), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _callNow(_center!.phone),
                              icon: const Icon(Icons.call, color: Color(0xFF1E3FE0)),
                              label: const Text('Call Now', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF1E3FE0)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _locationRow(Icons.location_on_outlined, 'Full Address', _center!.address),
                          const Divider(height: 24),
                          _locationRow(Icons.call_outlined, 'Phone', _center!.phone),
                          const Divider(height: 24),
                          _locationRow(Icons.mail_outline, 'Email', _center!.email.isNotEmpty ? _center!.email : 'Not provided'),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFFE3E9FF),
      child: const Icon(Icons.local_hospital_outlined, size: 48, color: Color(0xFF1E3FE0)),
    );
  }

  Widget _locationRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1E3FE0)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return 'General Hospital';
      case 'clinic':
        return 'Clinic';
      case 'lab':
        return 'Diagnostic Lab';
      default:
        return type;
    }
  }
}