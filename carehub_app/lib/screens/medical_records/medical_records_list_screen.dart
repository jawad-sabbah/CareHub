import 'package:flutter/material.dart';
import '../../models/medical_record.dart';
import '../../services/medical_record_service.dart';
import '../../core/api_exception.dart';
import '../../core/date_format.dart';
import 'medical_record_detail_screen.dart';

class MedicalRecordsListScreen extends StatefulWidget {
  const MedicalRecordsListScreen({super.key});

  @override
  State<MedicalRecordsListScreen> createState() => _MedicalRecordsListScreenState();
}

class _MedicalRecordsListScreenState extends State<MedicalRecordsListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All Visits'; // "All Visits" | "Hospital" | "Lab" | "Clinic"

  MedicalRecordsList? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final type = _selectedFilter == 'All Visits' ? 'all' : _selectedFilter.toLowerCase();
      final data = await MedicalRecordsService.getMedicalRecords(type: type);
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

  /// Search is client-side only - the backend's /medical-records endpoint
  /// has no search/diagnosis filter param, only `type`.
  List<MedicalRecordSummary> get _filteredRecords {
    final all = _data?.records ?? [];
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return all;
    return all.where((r) => r.diagnosis.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text('Medical History', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3FE0)),
          onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : null,
        ),
      ),
      body: _isLoading && _data == null
          // Only show the full-screen spinner on the very FIRST load,
          // when there's nothing on screen yet to preserve.
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _data == null
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
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search by diagnosis...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF1E3FE0), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Visits Recorded', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('${_data?.totalVisits ?? 0}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3FE0))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1E3FE0), Color(0xFF1652D6)]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: Colors.white),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Last Visit', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(
                                  _data?.lastVisit != null ? formatDisplayDate(_data!.lastVisit) : 'No visits yet',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: ['All Visits', 'Hospital', 'Lab', 'Clinic'].map((filter) {
                            final selected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ChoiceChip(
                                label: Text(filter),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() => _selectedFilter = filter);
                                  _load();
                                },
                                selectedColor: const Color(0xFF1E3FE0),
                                backgroundColor: const Color(0xFFE3E9FF),
                                labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF1E3FE0), fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Small inline indicator while a filter change is loading,
                      // instead of replacing the whole screen.
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_filteredRecords.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text('No medical records found.', style: TextStyle(color: Colors.grey))),
                        )
                      else
                        ..._filteredRecords.map(_recordCard),
                    ],
                  ),
                ),
    );
  }

  Widget _recordCard(MedicalRecordSummary record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: const Color(0xFFE3E9FF), child: Icon(_iconForType(record.centerType), color: const Color(0xFF1E3FE0))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.diagnosis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(record.center, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(formatDisplayDate(record.visitDate), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // No "Completed" status field exists on the backend - omitted
              // rather than fabricated. Empty SizedBox keeps "View Details"
              // aligned to the right, matching the design's layout balance.
              const SizedBox(),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MedicalRecordDetailScreen(recordId: record.id)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('View Details', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: Color(0xFF1E3FE0)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return Icons.local_hospital_outlined;
      case 'clinic':
        return Icons.medical_services_outlined;
      case 'lab':
        return Icons.science_outlined;
      default:
        return Icons.medical_information_outlined;
    }
  }
}