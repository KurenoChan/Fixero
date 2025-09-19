import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/chart_datamodel.dart';

class FixeroPieChart<T extends ChartDataModel> extends StatelessWidget {
  final List<T> data;

  const FixeroPieChart({super.key, required this.data});

  String _shortenLabel(String label, {int maxLength = 12}) {
    if (label.length <= maxLength) return label;
    return '${label.substring(0, maxLength)}…';
  }

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: data.asMap().entries.map((e) {
          final item = e.value;
          return PieChartSectionData(
            value: item.value,
            title:
                "${_shortenLabel(item.label)} (${item.value.toStringAsFixed(0)}%)",
            color: Colors.primaries[e.key % Colors.primaries.length].withAlpha(
              180,
            ),
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
      ),
    );
  }
}
