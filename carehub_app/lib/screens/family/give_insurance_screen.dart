import 'package:flutter/material.dart';
import '../../models/family_member.dart';
import '../../services/family_service.dart';
import '../../core/api_exception.dart';

const _brandBlue = Color(0xFF1E3FE0);

/// Shows the owner's family members (already in DB, attached via parent_id)
/// with a live search filter. No manual search button needed — the list
/// loads immediately and filters as you type.
class GiveInsuranceScreen extends StatefulWidget {
  const GiveInsuranceScreen({super.key});

  @override
  State<GiveInsuranceScreen> createState() => _GiveInsuranceScreenState();
}

class _GiveInsuranceScreenState extends State<GiveInsuranceScreen> {
  List<FamilyMember> _allMembers = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  String _query = '';

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
      final family = await FamilyService.getFamily();
      setState(() {
        // Exclude the primary holder — only show dependents
        _allMembers = family.members.where((m) => !m.isPrimary).toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  List<FamilyMember> get _filtered {
    if (_query.trim().isEmpty) return _allMembers;
    final q = _query.toLowerCase();
    return _allMembers
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.relation.toLowerCase().contains(q))
        .toList();
  }

  void _showMemberDetails(FamilyMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(member.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Relation', member.relation),
            const SizedBox(height: 8),
            _detailRow('Gender', member.gender),
            const SizedBox(height: 8),
            _detailRow('Date of Birth', member.dateOfBirth),
            const SizedBox(height: 8),
            _detailRow('Status', member.status),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: _brandBlue)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text('Family Members', style: TextStyle(color: _brandBlue, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _brandBlue),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search by name or relation',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text('${_filtered.length} member${_filtered.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Text(
                    _query.isEmpty ? 'No family members yet.' : 'No members match "$_query".',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _memberTile(_filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _memberTile(FamilyMember member) {
    final isActive = member.status.toLowerCase() == 'active';

    return InkWell(
      onTap: () => _showMemberDetails(member),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE3E9FF),
              child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: _brandBlue, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3E9FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(member.relation,
                            style: const TextStyle(fontSize: 11, color: _brandBlue, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text(member.gender, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isActive ? 'Insured' : 'Not insured',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}