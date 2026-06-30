import 'package:flutter/material.dart';
import '../../models/family_member.dart';
import '../../services/family_service.dart';
import '../../services/session.dart';
import '../../core/api_exception.dart';
import 'add_family_member_screen.dart';

class FamilyListScreen extends StatefulWidget {
  const FamilyListScreen({super.key});

  @override
  State<FamilyListScreen> createState() => _FamilyListScreenState();
}

class _FamilyListScreenState extends State<FamilyListScreen> {
  FamilyList? _family;
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
      final family = await FamilyService.getFamily();
      setState(() {
        _family = family;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmRemove(FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${member.name}?'),
        content: const Text('This will deactivate their access to the family policy.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FamilyService.removeFamilyMember(member.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${member.name} removed.')));
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade400));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text('Family Members', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF1E3FE0)),
      ),
      // Owner-only: inviting new members. Members can view this screen
      // but never see the add button, matching the role split you asked
      // for back on the Home screen.
      floatingActionButton: Session.isPrimary
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF1E3FE0),
              onPressed: () async {
                final added = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const AddFamilyMemberScreen()),
                );
                if (added == true) _load();
              },
              child: const Icon(Icons.person_add_alt_1, color: Colors.white),
            )
          : null,
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
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1E3FE0), Color(0xFF4A6FE8)]),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Your Coverage Plan', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Text('Total Members: ${_family!.totalMembers}',
                                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              radius: 24,
                              child: const Icon(Icons.people_alt_outlined, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Manage Dependents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_family!.planStatus.toUpperCase(),
                              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_family!.members.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: Text('No family members yet.', style: TextStyle(color: Colors.grey))),
                        )
                      else
                        ..._family!.members.map(_memberTile),
                    ],
                  ),
                ),
    );
  }

  Widget _memberTile(FamilyMember member) {
    final isActive = member.status.toLowerCase() == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Stack(
          children: [
            const CircleAvatar(backgroundColor: Color(0xFFE3E9FF), child: Icon(Icons.person, color: Color(0xFF1E3FE0))),
            if (member.isPrimary)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.shield, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFE3E9FF), borderRadius: BorderRadius.circular(10)),
              child: Text(member.isPrimary ? 'Primary' : 'Dependent',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF1E3FE0), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 6),
            Text(member.relation, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: isActive ? Colors.green.shade100 : Colors.red.shade100, borderRadius: BorderRadius.circular(20)),
              child: Text(member.status.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.green.shade800 : Colors.red.shade800)),
            ),
            // Owner can remove dependents (not themself), members see no
            // remove action at all - matches the role split.
            if (Session.isPrimary && !member.isPrimary)
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                onPressed: () => _confirmRemove(member),
              )
            else
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}