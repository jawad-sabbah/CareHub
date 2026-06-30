import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/insurance_history.dart';
import '../../services/insurance_history_service.dart';
import '../../core/api_exception.dart';
import '../../core/date_format.dart';

class InsuranceHistoryScreen extends StatefulWidget {
  const InsuranceHistoryScreen({super.key});

  @override
  State<InsuranceHistoryScreen> createState() => _InsuranceHistoryScreenState();
}

class _InsuranceHistoryScreenState extends State<InsuranceHistoryScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  InsuranceHistoryList? _data;
  bool _isLoading = true;
  String? _error;

  String? _selectedYear; // null = "All Years"
  final Set<int> _expandedIds = {};

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
      final data = await InsuranceHistoryService.getHistory(search: _searchController.text.trim());
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  /// Years filter is client-side only - the backend has no date-range
  /// filtering, so this just narrows down the already-fetched list by
  /// the year each entry's createdAt falls in.
  List<InsuranceHistoryEntry> get _filteredHistory {
    final all = _data?.history ?? [];
    if (_selectedYear == null) return all;
    return all.where((e) {
      final date = DateTime.tryParse(e.createdAt);
      return date != null && date.year.toString() == _selectedYear;
    }).toList();
  }

  List<String> get _availableYears {
    final years = (_data?.history ?? [])
        .map((e) => DateTime.tryParse(e.createdAt)?.year)
        .whereType<int>()
        .map((y) => y.toString())
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  /// Approximate "years covered" by summing each entry's policy date
  /// range in years - this is a rough client-side estimate since the
  /// backend has no such field. Distinct policy codes are deduplicated
  /// so a renewed policy's range isn't double counted.
  int get _yearsCovered {
    final seen = <String>{};
    int totalDays = 0;
    for (final e in _data?.history ?? []) {
      if (seen.contains(e.policyCode)) continue;
      seen.add(e.policyCode);
      final start = DateTime.tryParse(e.startDate);
      final end = DateTime.tryParse(e.expiryDate);
      if (start != null && end != null) {
        totalDays += end.difference(start).inDays;
      }
    }
    return (totalDays / 365).round();
  }

  Future<void> _pickYearFilter() async {
    final years = _availableYears;
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Years', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(ctx, null),
            ),
            ...years.map((y) => ListTile(title: Text(y), onTap: () => Navigator.pop(ctx, y))),
          ],
        ),
      ),
    );
    setState(() => _selectedYear = selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text('Insurance History', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
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
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search by policy name or code...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _pickYearFilter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(color: const Color(0xFF1E3FE0), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(_selectedYear ?? 'All Years', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _statCard(Icons.history, const Color(0xFFE3E9FF), const Color(0xFF1E3FE0), 'Total Policies', _data!.totalPolicies.toString())),
                          const SizedBox(width: 14),
                          Expanded(child: _statCard(Icons.verified_outlined, const Color(0xFFD6F5E3), Colors.green.shade700, 'Years Covered', '$_yearsCovered Years')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_filteredHistory.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text('No insurance history found.', style: TextStyle(color: Colors.grey))),
                        )
                      else
                        ..._filteredHistory.map(_historyCard),
                    ],
                  ),
                ),
    );
  }

  Widget _statCard(IconData icon, Color iconBg, Color iconColor, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: iconBg, child: Icon(icon, color: iconColor, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(InsuranceHistoryEntry entry) {
    final isExpanded = _expandedIds.contains(entry.id);
    final badge = _badgeFor(entry.actionType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(entry.planName.isNotEmpty ? '${entry.planName} Plan' : 'Insurance Plan',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: badge.bg, borderRadius: BorderRadius.circular(20)),
                child: Text(badge.label, style: TextStyle(color: badge.fg, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Policy Code: ', style: TextStyle(color: Colors.grey)),
                TextSpan(text: entry.policyCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text('${formatDisplayDate(entry.startDate)} - ${formatDisplayDate(entry.expiryDate)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: badge.label == 'Renewed'
                ? ElevatedButton(
                    onPressed: () => setState(() {
                      isExpanded ? _expandedIds.remove(entry.id) : _expandedIds.add(entry.id);
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3FE0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(isExpanded ? 'Hide Details' : 'View Details', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                : OutlinedButton.icon(
                    onPressed: () => setState(() {
                      isExpanded ? _expandedIds.remove(entry.id) : _expandedIds.add(entry.id);
                    }),
                    icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF1E3FE0)),
                    label: Text(isExpanded ? 'Hide History' : 'History', style: const TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1E3FE0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(10)),
              child: Text(entry.description.isNotEmpty ? entry.description : 'No additional details available.',
                  style: const TextStyle(color: Colors.black87, height: 1.4)),
            ),
          ],
        ],
      ),
    );
  }

  _Badge _badgeFor(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'renewed':
        return _Badge('Renewed', Colors.green.shade100, Colors.green.shade800);
      case 'expired':
        return _Badge('Expired', Colors.grey.shade300, Colors.grey.shade800);
      case 'used':
        return _Badge('Used', const Color(0xFFE3E9FF), const Color(0xFF1E3FE0));
      default:
        return _Badge(actionType, Colors.grey.shade200, Colors.grey.shade700);
    }
  }
}

class _Badge {
  final String label;
  final Color bg;
  final Color fg;
  _Badge(this.label, this.bg, this.fg);
}