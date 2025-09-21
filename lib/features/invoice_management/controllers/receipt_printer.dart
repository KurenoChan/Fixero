import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Relative import to your model:
import '../models/Invoice.dart';

class ReceiptPrinter {
  static Future<void> printInvoice(Invoice inv) async {
    final bytes = await _buildPdf(inv);
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  static Future<Uint8List> _buildPdf(Invoice inv) async {
    final doc = pw.Document();
    final currency = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);
    final issued = _fmtYmd(inv.issuedDate);
    final paidAt = _fmtYmd(inv.dueDate);
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('FIXERO', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Official Receipt', style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: 'invoice:${inv.invoiceNo ?? "-"}',
                width: 64,
                height: 64,
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          _kvCard({
            'Receipt No': inv.invoiceNo ?? '-',
            'Issued Date': issued,
            'Paid At': paidAt,
            'Status': inv.status ?? '-',
            'Job ID': inv.jobID ?? '-',
            if ((inv.jobDescription ?? '').isNotEmpty) 'Job': inv.jobDescription!,
            if ((inv.jobServiceType ?? '').isNotEmpty) 'Service Type': inv.jobServiceType!,
          }),

          pw.SizedBox(height: 18),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {0: const pw.FlexColumnWidth(3), 1: const pw.FlexColumnWidth(1)},
            children: [
              _th(['Description', 'Amount (RM)']),
              _tr(['Total', currency.format(inv.totalAmount ?? 0)]),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.grey400),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Generated on $today', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Thank you for your payment.', textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );

    return doc.save();
  }

  // ---------- helpers ----------
  static String _fmtYmd(String? ymd) {
    if (ymd == null || ymd.isEmpty) return '-';
    final p = ymd.split('-'); // expect YYYY-MM-DD from your model
    if (p.length != 3) return ymd;
    return '${p[2]}/${p[1]}/${p[0]}'; // DD/MM/YYYY
  }

  static pw.Widget _kvCard(Map<String, String> data) => pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: data.entries
              .map((e) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(e.key, style: pw.TextStyle(color: PdfColors.grey700)),
                        pw.Text(e.value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );

  static pw.TableRow _th(List<String> cells) => pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: cells
            .map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(c, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ))
            .toList(),
      );

  static pw.TableRow _tr(List<String> cells) => pw.TableRow(
        children: cells
            .map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(c),
                ))
            .toList(),
      );
}
