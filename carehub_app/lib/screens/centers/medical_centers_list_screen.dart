import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/medical_center.dart';
import '../../services/medical_center_service.dart';
import '../../core/api_exception.dart';
import 'medical_center_detail_screen.dart';

class MedicalCentersListScreen extends StatefulWidget {
  const MedicalCentersListScreen({super.key});

  @override
  State<MedicalCentersListScreen> createState() => _MedicalCentersListScreenState();
}

class _MedicalCentersListScreenState extends State<MedicalCentersListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All Centers'; // "All Centers" | "Hospital" | "Clinic" | "Lab"
  List<MedicalCenterSummary> _centers = [];
  bool _isLoading = true;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<MedicalCenterSummary> centers;
      final query = _searchController.text.trim();

      if (query.isNotEmpty) {
        centers = await MedicalCenterService.search(query);
      } else if (_selectedFilter == 'All Centers') {
        centers = await MedicalCenterService.getAll();
      } else {
        centers = await MedicalCenterService.getByType(_selectedFilter.toLowerCase());
      }

      setState(() {
        _centers = centers;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        // "No medical centers found" comes back as a 500 from the backend
        // for an empty list - treat it as an empty result, not a hard error,
        // so the UI shows "no centers" instead of a scary error screen.
        if (e.message.toLowerCase().contains('no medical centers found')) {
          _centers = [];
          _error = null;
        } else {
          _error = e.message;
        }
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  void _onFilterSelected(String filter) {
    setState(() => _selectedFilter = filter);
    _searchController.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text('Medical Center', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF1E3FE0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // This screen is acting as a bottom-nav tab root (no previous
              // route) - in that case there's nothing to "go back" to here;
              // the bottom nav itself handles switching to Home.
            }
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Find centers or specialties...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: ['All Centers', 'Hospital', 'Clinic', 'Lab'].map((filter) {
                final selected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (_) => _onFilterSelected(filter),
                    selectedColor: const Color(0xFF1E3FE0),
                    backgroundColor: const Color(0xFFE3E9FF),
                    labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF1E3FE0), fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
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
                    : _centers.isEmpty
                        ? const Center(child: Text('No medical centers found.', style: TextStyle(color: Colors.grey)))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              children: [
                                ..._centers.map(_centerTile),
                                const SizedBox(height: 30),
                                const Center(child: Text('"', style: TextStyle(fontSize: 50, color: Color(0xFFB9C6F2)))),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    '"Your health is our priority. We are here to connect you with the best care possible."',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(0xFF1E3FE0), fontStyle: FontStyle.italic, fontSize: 15),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _centerTile(MedicalCenterSummary center) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE3E9FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_iconForType(center.type), color: const Color(0xFF1E3FE0)),
        ),
        title: Row(
          children: [
            Expanded(child: Text(center.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))),
            Text(
              center.isOpen ? 'Open' : 'Closed',
              style: TextStyle(color: center.isOpen ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        subtitle: Text(center.address, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MedicalCenterDetailScreen(centerId: center.id)),
        ),
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
        return Icons.add_box_outlined;
    }
  }
}