import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// We keep the generic type so existing calls compile,
// but we ignore the incoming data and plot PAID invoices from Firebase instead.
abstract class ChartDataModel {
  String get label;
  double get value;
}

class FixeroLineChart<T extends ChartDataModel> extends StatefulWidget {
  /// Kept for backward compatibility with the existing call site, but ignored.
  final List<T> data;

  final Color color;
  final bool showDot;
  final bool showGradient;

  const FixeroLineChart({
    super.key,
    required this.data, // <-- kept, but not used
    this.color = Colors.blue,
    this.showDot = false,
    this.showGradient = true,
  });

  @override
  State<FixeroLineChart<T>> createState() => _FixeroLineChartState<T>();
}

class _FixeroLineChartState<T extends ChartDataModel>
    extends State<FixeroLineChart<T>> {
  StreamSubscription<DatabaseEvent>? _sub;
  List<_Point> _points = const [];

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
    final ref = FirebaseDatabase.instance.ref('invoices');
    _sub = ref.onValue.listen((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) {
        setState(() => _points = const []);
        return;
      }

      // Aggregate totals by YYYY-MM for PAID invoices
      final Map<String, double> monthTotals = {};
      raw.forEach((_, v) {
        if (v is Map) {
          final status = (v['status'] ?? '').toString().toLowerCase();
          if (status != 'paid') return;

          // Amount
          final amt = (v['totalAmount'] is num)
              ? (v['totalAmount'] as num).toDouble()
              : double.tryParse('${v['totalAmount']}') ?? 0.0;
          if (amt <= 0) return;

          // Prefer paidAt; fallback to issuedDate; formats like "YYYY-MM-DD" or "YYYY-MM-DD HH:mm"
          final whenStr = (v['paidAt'] ?? v['issuedDate'] ?? '').toString();
          if (whenStr.isEmpty) return;

          DateTime? dt;
          try {
            final dateOnly = whenStr.split(' ').first;
            final p = dateOnly.split('-'); // [YYYY, MM, DD]
            if (p.length >= 2) {
              final y = int.tryParse(p[0]) ?? 0;
              final m = int.tryParse(p[1]) ?? 0;
              final d = (p.length >= 3) ? int.tryParse(p[2]) ?? 1 : 1;
              dt = DateTime(y, m, d);
            }
          } catch (_) {
            dt = null;
          }
          if (dt == null) return;

          final key =
              '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}';
          monthTotals[key] = (monthTotals[key] ?? 0.0) + amt;
        }
      });

      // Build last 12 months, oldest -> newest
      final now = DateTime.now();
      final months = List<DateTime>.generate(12, (i) {
        final m = DateTime(now.year, now.month - (11 - i), 1);
        return DateTime(m.year, m.month, 1);
      });

      String label(DateTime d) {
        const names = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        final yy = (d.year % 100).toString().padLeft(2, '0'); // e.g. 24 or 25
        return '${names[d.month - 1]} $yy'; // e.g. "Jan 25"
      }

      final pts = <_Point>[];
      for (final m in months) {
        final key =
            '${m.year.toString().padLeft(4, '0')}-${m.month.toString().padLeft(2, '0')}';
        final total = monthTotals[key] ?? 0.0;
        pts.add(_Point(label(m), total));
      }

      setState(() => _points = pts);
    }, onError: (_) {
      setState(() => _points = const []);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_points.isEmpty || _points.any((p) => !p.value.isFinite)) {
      return const Center(child: Text("No income yet"));
    }

    final spots = _points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    final maxY = _points.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minY = 0.0;
    final intervalY = ((maxY - minY) / 4).ceilToDouble().clamp(1.0, double.infinity);

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: (maxY * 1.1).clamp(10, double.infinity),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 2,
                dotData: FlDotData(show: widget.showDot),
                color: widget.color,
                belowBarData: BarAreaData(
                  show: widget.showGradient,
                  gradient: LinearGradient(
                    colors: [
                      widget.color.withAlpha(30),
                      widget.color.withAlpha(0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: intervalY,
                  reservedSize: 40,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2, // show every 2nd month for readability
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < _points.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _points[idx].label, // e.g. "Jan 25"
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: true),
          ),
        ),
      ),
    );
  }
}

class _Point {
  final String label;
  final double value;
  const _Point(this.label, this.value);
}
