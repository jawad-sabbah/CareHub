import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/medical_record.dart';
import 'date_format.dart';

/// Builds and downloads a PDF report for a visit, using only data
/// already loaded on the Visit Details screen - no network call
/// needed, since everything is already in memory.
class PdfReport {
  static Future<void> generateAndShare(MedicalRecordDetail record) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _header(),
              pw.SizedBox(height: 20),
              _visitSummary(record),
              pw.SizedBox(height: 20),
              _clinicalNotes(record),
              pw.SizedBox(height: 20),
              _servicesTable(record),
              pw.SizedBox(height: 20),
              _totalsSummary(record),
              pw.SizedBox(height: 30),
              _footer(),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();

    // sharePdf triggers a direct download on web (no print preview dialog),
    // and opens the native share sheet on Android/iOS - no print-specific
    // UI either way, just "save/share this file."
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Visit_Report_${record.id}.pdf',
    );
  }

  static pw.Widget _header() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'HealthLink',
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3FE0')),
        ),
        pw.Text(
          'Visit Report',
          style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
        ),
      ],
    );
  }

  static pw.Widget _visitSummary(MedicalRecordDetail record) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#EFF3FF'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('PRIMARY DIAGNOSIS', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(
            record.diagnosis.isNotEmpty ? record.diagnosis : 'No diagnosis recorded',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          if (record.icd10Code.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text('ICD-10: ${record.icd10Code}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          ],
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text('Visit Date: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.Text(formatDisplayDate(record.visitDate), style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Text('Medical Center: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.Text(record.centerName, style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _clinicalNotes(MedicalRecordDetail record) {
    if (record.services.isEmpty) return pw.SizedBox();
    final first = record.services.first;
    if (first.chiefComplaint.isEmpty && first.physicalExam.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Clinical Notes', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (first.chiefComplaint.isNotEmpty) ...[
          pw.Text('Chief Complaint', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3FE0'))),
          pw.SizedBox(height: 2),
          pw.Text(first.chiefComplaint, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 8),
        ],
        if (first.physicalExam.isNotEmpty) ...[
          pw.Text('Physical Exam', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E3FE0'))),
          pw.SizedBox(height: 2),
          pw.Text(first.physicalExam, style: const pw.TextStyle(fontSize: 11)),
        ],
      ],
    );
  }

  static pw.Widget _servicesTable(MedicalRecordDetail record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Services & Costs', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(1.2),
            2: pw.FlexColumnWidth(1.2),
            3: pw.FlexColumnWidth(1.2),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#1E3FE0')),
              children: [
                _tableHeaderCell('Service'),
                _tableHeaderCell('Cost'),
                _tableHeaderCell('Coverage'),
                _tableHeaderCell('You Pay'),
              ],
            ),
            ...record.services.map((s) => pw.TableRow(
                  children: [
                    _tableCell(s.serviceName, bold: true),
                    _tableCell('\$${s.cost.toStringAsFixed(2)}'),
                    _tableCell('${s.coveragePercentage}%'),
                    _tableCell('\$${s.patientPays.toStringAsFixed(2)}'),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
    );
  }

  static pw.Widget _tableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );
  }

  static pw.Widget _totalsSummary(MedicalRecordDetail record) {
    final totalCost = record.services.fold<double>(0, (sum, s) => sum + s.cost);
    final totalCovered = record.services.fold<double>(0, (sum, s) => sum + s.insurancePays);
    final totalPatient = record.services.fold<double>(0, (sum, s) => sum + s.patientPays);

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _totalRow('Total Cost:', totalCost),
          _totalRow('Insurance Covered:', -totalCovered, color: PdfColors.green700),
          pw.SizedBox(height: 4),
          pw.Container(width: 200, height: 1, color: PdfColors.grey400),
          pw.SizedBox(height: 4),
          _totalRow('You Paid:', totalPatient, bold: true, color: PdfColor.fromHex('#1E3FE0')),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(String label, double value, {bool bold = false, PdfColor? color}) {
    final display = value < 0 ? '-\$${(-value).toStringAsFixed(2)}' : '\$${value.toStringAsFixed(2)}';
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(label, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 11, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          ),
          pw.SizedBox(width: 10),
          pw.SizedBox(
            width: 70,
            child: pw.Text(display, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 11, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 6),
        pw.Text(
          'This report was generated by the HealthLink app for personal record-keeping. '
          'It is not a substitute for an official insurance claim document.',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ],
    );
  }

}