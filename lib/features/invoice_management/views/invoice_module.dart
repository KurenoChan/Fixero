import 'dart:async';
import 'package:fixero/features/invoice_management/models/invoice.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class InvoiceModule extends StatefulWidget {
  const InvoiceModule({super.key});

  @override
  State<InvoiceModule> createState() => InvoiceModuleState();
}

class InvoiceModuleState extends State<InvoiceModule> {
  final _db = FirebaseDatabase.instance;
  int _segment = 0; // 0 = Unpaid, 1 = Paid
  String _query = '';

  StreamSubscription<DatabaseEvent>? _sub;
  List<Invoice> _all = [];

  @override
  void initState() {
    super.initState();
    _listenInvoices();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _listenInvoices() {
    _sub?.cancel();
    _sub = _db.ref('invoices').onValue.listen((event) async {
      final raw = event.snapshot.value;
      final List<Invoice> loaded = [];
      if (raw is Map) {
        // Build the list (and also fetch job descriptions)
        for (final entry in raw.entries) {
          final v = entry.value;
          if (v is Map) {
            final inv = Invoice.fromMap(Map<String, dynamic>.from(v));
            // Fetch its job (for description)
            if (inv.jobID != null && inv.jobID!.isNotEmpty) {
              final jobSnap = await _db.ref('jobservices/jobs/${inv.jobID}').get();
              if (jobSnap.exists && jobSnap.value is Map) {
                final jm = Map<String, dynamic>.from(jobSnap.value as Map);
                inv.jobDescription = (jm['jobDescription'] ?? '').toString();
                inv.jobServiceType = (jm['jobServiceType'] ?? '').toString();
              }
            }
            loaded.add(inv);
          }
        }
      }
      // newest first by issuedDate string (YYYY-MM-DD)
      loaded.sort((a, b) => (b.issuedDate ?? '').compareTo(a.issuedDate ?? ''));
      if (mounted) setState(() => _all = loaded);
    }, onError: (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load invoices: $e')),
      );
    });
  }

  List<Invoice> get _filtered {
    final wantPaid = _segment == 1;
    return _all.where((inv) {
      final paid = (inv.status ?? '').toLowerCase() == 'paid';
      if (paid != wantPaid) return false;

      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      final hay = [
        inv.invoiceNo ?? '',
        inv.jobID ?? '',
        inv.jobDescription ?? '',
        inv.jobServiceType ?? '',
      ].join(' ').toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  int get _unpaidCount =>
      _all.where((i) => (i.status ?? '').toLowerCase() != 'paid').length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    BoxDecoration segStyle(bool on) => BoxDecoration(
      color: on ? theme.colorScheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [Icon(Icons.info_outline)],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Segment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _segment = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: segStyle(_segment == 0),
                        child: Center(
                          child: Text(
                            'Unpaid',
                            style: TextStyle(
                              color: _segment == 0
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _segment = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: segStyle(_segment == 1),
                        child: Center(
                          child: Text(
                            'Paid',
                            style: TextStyle(
                              color: _segment == 1
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search invoice id / job id / description...',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No invoices found.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = _filtered[i];
                      return InvoiceCard(
                        item: item,
                        onOpen: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => InvoiceDetailPage(inv: item),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Footer count for unpaid
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Unpaid: $_unpaidCount'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class InvoiceCard extends StatelessWidget {
  final Invoice item;
  final VoidCallback? onOpen;
  const InvoiceCard({super.key, required this.item, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paid = (item.status ?? '').toLowerCase() == 'paid';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: title + actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job description (or service type)
                        Text(
                          item.jobDescription?.isNotEmpty == true
                              ? item.jobDescription!
                              : (item.jobServiceType ?? 'Service'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        // Date line: Due for unpaid / Paid At for paid
                        Text(
                          paid
                              ? 'Paid At : ${_fmt(item.dueDate)}'
                              : 'Due Date : ${_fmt(item.dueDate)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        // IDs
                        Text(
                          'Invoice: ${item.invoiceNo ?? '-'} • Job: ${item.jobID ?? '-'}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onOpen,
                    icon: const Icon(Icons.remove_red_eye_outlined),
                    tooltip: 'View',
                  ),
                  FilledButton.tonal(
                    onPressed: onOpen,
                    child: const Text('View'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'RM ${((item.totalAmount ?? 0) * 1.0).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (!paid)
                    FilledButton.tonal(
                      onPressed: () {},
                      child: const Text('Unpaid'),
                    )
                  else
                    Row(
                      children: [
                        const Icon(Icons.cloud_done_outlined, size: 18),
                        const SizedBox(width: 6),
                        TextButton(
                          onPressed: onOpen,
                          child: const Text('Receipt'),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvoiceDetailPage extends StatelessWidget {
  final Invoice inv;
  const InvoiceDetailPage({super.key, required this.inv});

  @override
  Widget build(BuildContext context) {
    final paid = (inv.status ?? '').toLowerCase() == 'paid';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text('Invoice'),
        actions: const [Icon(Icons.info_outline)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              Center(
                child: Column(
                  children: [
                    Text('Invoice: ${inv.invoiceNo ?? '-'}',
                        style: _muted()),
                    const SizedBox(height: 4),
                    Text(
                      inv.jobDescription?.isNotEmpty == true
                          ? inv.jobDescription!
                          : (inv.jobServiceType ?? 'Service'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text('Job ID: ${inv.jobID ?? '-'}', style: _muted()),
                    Text('Issued At: ${_fmt(inv.issuedDate)}', style: _muted()),
                    Text(
                      paid
                          ? 'Paid At: ${_fmt(inv.dueDate)}'
                          : 'Due Date: ${_fmt(inv.dueDate)}',
                      style: _muted(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      'RM ${((inv.totalAmount ?? 0) * 1.0).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Simple fee table placeholder — you can wire actual line items later
              _FeeTable(total: (inv.totalAmount ?? 0) * 1.0),

              
              if (!paid) const SizedBox(height: 4),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _muted() => TextStyle(color: Colors.grey.shade600, fontSize: 12);
}

class _FeeTable extends StatelessWidget {
  final double total;
  const _FeeTable({required this.total});

  @override
  Widget build(BuildContext context) {
    // placeholder demo rows
    final rows = const [
      ['Service Fee', 120.00],
      ['Parts', 210.00],
      ['Labour', 180.00],
      ['Discount', -100.00],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Table(
        columnWidths: const {1: IntrinsicColumnWidth()},
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade200),
          outside: BorderSide(color: Colors.grey.shade200),
        ),
        children: [
          _headerRow('Fee', 'Amount'),
          ...rows.map((r) => _dataRow(r[0] as String, (r[1] as double))),
          _footerRow('Total', total),
        ],
      ),
    );
  }

  TableRow _headerRow(String a, String b) => TableRow(children: [
        _cell(a, bold: true, bg: true),
        _cell(b, alignEnd: true, bold: true, bg: true),
      ]);

  TableRow _dataRow(String a, double b) => TableRow(children: [
        _cell(a),
        _cell('RM ${b.toStringAsFixed(2)}', alignEnd: true),
      ]);

  TableRow _footerRow(String a, double b) => TableRow(children: [
        _cell(a, bold: true, bg: true),
        _cell('RM ${b.toStringAsFixed(2)}',
            alignEnd: true, bold: true, bg: true),
      ]);

  Widget _cell(String text,
      {bool alignEnd = false, bool bold = false, bool bg = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: bg ? const Color(0xFFF8FAFC) : null,
      child: Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// -------- utils
String _fmt(String? yyyyMmDd) {
  if (yyyyMmDd == null || yyyyMmDd.isEmpty) return '-';
  // Expecting "YYYY-MM-DD"
  final parts = yyyyMmDd.split('-');
  if (parts.length != 3) return yyyyMmDd;
  final y = parts[0], m = parts[1], d = parts[2];
  return '$d/$m/$y';
}
