import 'package:flutter/material.dart';
import '../../models/medical_record.dart';
import '../../services/medical_record_service.dart';
import '../../core/api_exception.dart';
import '../../core/date_format.dart';
import '../../core/pdf_report.dart';

class MedicalRecordDetailScreen extends StatefulWidget {
  final int recordId;
  const MedicalRecordDetailScreen({super.key, required this.recordId});

  @override
  State<MedicalRecordDetailScreen> createState() => _MedicalRecordDetailScreenState();
}

class _MedicalRecordDetailScreenState extends State<MedicalRecordDetailScreen> {
  MedicalRecordDetail? _record;
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
      final record = await MedicalRecordsService.getRecordDetail(widget.recordId);
      setState(() {
        _record = record;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPdf() async {
    if (_record == null) return;
    try {
      await PdfReport.generateAndShare(_record!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate PDF: $e'), backgroundColor: Colors.red.shade400),
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
        title: const Text('Visit Details', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
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
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _diagnosisCard(_record!),
                    const SizedBox(height: 20),
                    if (_record!.services.isNotEmpty) _clinicalNotesCard(_record!.services.first),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFFD6F5E3), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.assignment_outlined, color: Colors.green, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Text('Services & Costs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_record!.services.isEmpty)
                            const Text('No services recorded for this visit.', style: TextStyle(color: Colors.grey))
                          else
                            ..._record!.services.map(_serviceCard),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _downloadPdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3FE0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
                        label: const Text('Download PDF Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _diagnosisCard(MedicalRecordDetail r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3FE0), Color(0xFF4A6FE8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PRIMARY DIAGNOSIS', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(r.diagnosis.isNotEmpty ? r.diagnosis : 'No diagnosis recorded',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (r.icd10Code.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('ICD-10: ${r.icd10Code}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(formatDisplayDate(r.visitDate), style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(r.centerName, style: const TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _clinicalNotesCard(MedicalRecordService firstService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE3E9FF), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.description_outlined, color: Color(0xFF1E3FE0), size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Clinical Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (firstService.chiefComplaint.isNotEmpty) ...[
            const Text('Chief Complaint', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(firstService.chiefComplaint, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 14),
          ],
          if (firstService.physicalExam.isNotEmpty) ...[
            const Text('Physical Exam', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(firstService.physicalExam, style: const TextStyle(height: 1.4)),
          ],
        ],
      ),
    );
  }

  Widget _serviceCard(MedicalRecordService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(service.serviceName, style: const TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          if (service.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(service.description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
          const Divider(height: 16),
          _costRow('Cost:', service.cost, bold: true),
          _costRow('Coverage:', -service.insurancePays, color: Colors.green.shade700),
          _costRow('Total:', service.patientPays, bold: true, color: const Color(0xFF1E3FE0)),
        ],
      ),
    );
  }

  Widget _costRow(String label, double value, {bool bold = false, Color? color}) {
    final sign = value < 0 ? '-\$${(-value).toStringAsFixed(2)}' : '\$${value.toStringAsFixed(2)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(sign, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}