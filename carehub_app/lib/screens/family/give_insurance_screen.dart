import 'package:flutter/material.dart';
import '../../models/family_member.dart';
import '../../services/family_service.dart';
import '../../core/api_exception.dart';

const _brandBlue = Color(0xFF1E3FE0);

/// Give Insurance: search the owner's *inactive* dependents (members a
/// "remove" deactivated) and reactivate one so they reappear on the plan.
class GiveInsuranceScreen extends StatefulWidget {
  const GiveInsuranceScreen({super.key});

  @override
  State<GiveInsuranceScreen> createState() => _GiveInsuranceScreenState();
}

class _GiveInsuranceScreenState extends State<GiveInsuranceScreen> {
  List<EligibleMember> _members = [];
  bool _isLoading = false;
  bool _reactivatedAny = false; // tells the family list to reload on pop
  String? _error;
  int? _busyMemberId; // which row is currently being reactivated

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Show all inactive dependents up front, before any typing.
    _search('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String value) async {
    final term = value.trim();
    setState(() {
      _query = value;
      _error = null;
      _isLoading = true;
    });

    try {
      final results = await FamilyService.searchInactiveMembers(term);
      if (!mounted) return;
      setState(() {
        _members = results;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmReactivate(EligibleMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Give insurance to ${member.name}?'),
        content: const Text('This reactivates their access to the family policy.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reactivate')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busyMemberId = member.id);
    try {
      await FamilyService.reactivateMember(memberId: member.id);
      if (!mounted) return;
      _reactivatedAny = true;
      // Drop the reactivated member from the (inactive) results list.
      setState(() {
        _members = _members.where((m) => m.id != member.id).toList();
        _busyMemberId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${member.name} reactivated.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busyMemberId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade400),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_reactivatedAny);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F6FA),
          elevation: 0,
          title: const Text('Give Insurance',
              style: TextStyle(color: _brandBlue, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: _brandBlue),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_reactivatedAny),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: 'Search removed members by name or email',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _search('');
                          },
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.grey)));
    }
    if (_members.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty
              ? 'No removed members to reactivate.'
              : 'No removed members match "$_query".',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _memberCard(_members[index]),
    );
  }

  Widget _memberCard(EligibleMember member) {
    final isBusy = _busyMemberId == member.id;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isBusy ? null : () => _confirmReactivate(member),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE3E9FF),
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: const TextStyle(color: _brandBlue, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(member.email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (isBusy)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else
              const Icon(Icons.add_circle_outline, color: _brandBlue),
          ],
        ),
      ),
    );
  }
}