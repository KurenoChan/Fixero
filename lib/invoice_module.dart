import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class InvoiceModule extends StatefulWidget {
  static const routeName = '/invoices';
  const InvoiceModule({super.key});

  @override
  State<InvoiceModule> createState() => _InvoiceModuleState();
}

class _InvoiceModuleState extends State<InvoiceModule> {
  int segment = 0; // 0 = Unpaid, 1 = Paid
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('invoices');
final snap = await ref.get();
final data = (snap.value as Map?) ?? {};
final list = data.values.map((e) {
  final m = Map<String, dynamic>.from(e as Map);
  return InvoiceItem(
    invoiceNo: m['invoiceNo'] ?? '',
    jobID:     m['jobID'] ?? '',
    status:    m['status'] ?? 'Unpaid',
    issuedDate: m['issuedDate'] ?? '',
    dueDate:    m['dueDate'] ?? '',
    totalAmount: (m['totalAmount'] is num) ? (m['totalAmount'] as num).toDouble() : 0.0,
  );
}).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [Icon(Icons.info_outline)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SegmentBar(
                value: segment,
  labels: const ['Unpaid', 'Paid'], // <-- rename
  onChanged: (v) => setState(() => segment = v),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search invoice no / job id…',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: ref.onValue,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }

                  final data = snap.data?.snapshot.value;
                  if (data is! Map) {
                    return const Center(child: Text('No invoices found'));
                  }

                  final invoices = <InvoiceItem>[];
                  data.forEach((_, v) {
                    if (v is Map) {
                      final item = InvoiceItem.fromMap(v.cast<String, dynamic>());
                      invoices.add(item);
                    }
                  });

                  // filter by segment + query
                  final filtered = invoices.where((inv) {
  final matchStatus = segment == 0 ? inv.status == 'Unpaid' : inv.status == 'Paid';
  final matchQuery  = query.isEmpty ||
      inv.invoiceNo.toLowerCase().contains(query.toLowerCase()) ||
      inv.jobID.toLowerCase().contains(query.toLowerCase());
  return matchStatus && matchQuery;
}).toList();
                    ..sort((a, b) => (b.issuedDate ?? '').compareTo(a.issuedDate ?? ''));

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return InvoiceCard(
                        item: item,
                        showReceipt: item.status.toLowerCase() == 'paid',
                        onView: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => InvoiceDetailPage(item: item)),
                        ),
                        onReceipt: item.status.toLowerCase() == 'paid'
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => InvoiceDetailPage(item: item)),
                                )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  final int value; // 0 pending, 1 paid
  final ValueChanged<int> onChanged;
  const _SegmentBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      padding: const EdgeInsets.all(4),
      child: Row(children: [_seg('Pending', 0), _seg('Paid', 1)]),
    );
  }

  Expanded _seg(String label, int idx) {
    final isSelected = value == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InvoiceItem {
  final String invoiceNo;
  final String? issuedDate;
  final String? dueDate;
  final String status;       // Paid / Unpaid / Pending
  final double? totalAmount;
  final String? jobID;

  InvoiceItem({
    required this.invoiceNo,
    required this.status,
    this.issuedDate,
    this.dueDate,
    this.totalAmount,
    this.jobID,
  });

  factory InvoiceItem.fromMap(Map<String, dynamic> m) {
    return InvoiceItem(
      invoiceNo: (m['invoiceNo'] ?? '').toString(),
      status: (m['status'] ?? '').toString(),
      issuedDate: m['issuedDate']?.toString(),
      dueDate: m['dueDate']?.toString(),
      totalAmount: m['totalAmount'] is num ? (m['totalAmount'] as num).toDouble() : null,
      jobID: m['jobID']?.toString(),
    );
  }
}

class InvoiceCard extends StatelessWidget {
  final InvoiceItem item;
  final VoidCallback? onView;
  final VoidCallback? onReceipt;
  final bool showReceipt;
  const InvoiceCard({
    super.key,
    required this.item,
    this.onView,
    this.onReceipt,
    this.showReceipt = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.status == 'Paid' ? 'Service Bill' : 'Pending Bill',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  item.status == 'Paid'
                      ? 'Paid Date : ${item.dueDate ?? '-'}'
                      : 'Issue Date : ${item.issuedDate ?? '-'}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(item.invoiceNo, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ]),
            ),
            IconButton(onPressed: onView, icon: const Icon(Icons.remove_red_eye_outlined), tooltip: 'View'),
            FilledButton.tonal(onPressed: onView, child: const Text('View')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Text(
              item.totalAmount != null ? 'RM ${item.totalAmount!.toStringAsFixed(2)}' : 'RM -',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (item.status.toLowerCase() != 'paid')
              FilledButton.tonal(onPressed: onView, child: const Text('Pending')),
            if (showReceipt)
              Row(children: [
                const Icon(Icons.cloud_done_outlined, size: 18),
                const SizedBox(width: 6),
                TextButton(onPressed: onReceipt, child: const Text('Receipt')),
              ]),
          ]),
        ]),
      ),
    );
  }
}

class InvoiceDetailPage extends StatelessWidget {
  final InvoiceItem item;
  const InvoiceDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
        title: const Text('Invoice'),
        actions: const [Icon(Icons.info_outline)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 6),
            Center(
              child: Column(children: [
                Text('No.Bill: ${item.invoiceNo}', style: _muted()),
                const SizedBox(height: 4),
                const Text('Service Name', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Issue Date: ${item.issuedDate ?? '-'}', style: _muted()),
                Text('Due Date: ${item.dueDate ?? '-'}', style: _muted()),
              ]),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            Center(
              child: Column(children: [
                const Text('Total Amount', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  item.totalAmount != null ? 'RM ${item.totalAmount!.toStringAsFixed(2)}' : 'RM -',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ]),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print_outlined),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              label: const Text('Print Receipt'),
            ),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
  }

  TextStyle _muted() => TextStyle(color: Colors.grey.shade600, fontSize: 12);
}
