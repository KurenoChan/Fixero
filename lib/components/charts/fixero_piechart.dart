import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../model/chart_datamodel.dart';

class FixeroPieChart<T extends ChartDataModel> extends StatelessWidget {
  final List<T> data;

  const FixeroPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: data.asMap().entries.map((e) {
          final item = e.value;
          return PieChartSectionData(
            value: item.value,
            title: "${item.label} (${item.value.toStringAsFixed(0)}%)",
            color: Colors.primaries[e.key % Colors.primaries.length],
            radius: 60,
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          );
        }).toList(),
      ),
    );
  }
}
