import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../model/chart_datamodel.dart';

class FixeroBarChart<T extends ChartDataModel> extends StatelessWidget {
  final List<T> data;
  final Color color;

  const FixeroBarChart({
    super.key,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.any((d) => !d.value.isFinite)) {
      return const Center(child: Text("Invalid or empty data"));
    }

    final double maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final double intervalY = (maxY / 4).ceilToDouble();

    return SizedBox(
      height: 250, // ✅ Fix: Add fixed height
      child: BarChart(
        BarChartData(
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value,
                  color: color,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: intervalY > 0 ? intervalY : 5, // ✅ Fix: safe interval
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) {
                  int index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Transform.rotate(
                      angle: -0.5,
                      alignment: Alignment.topRight,
                      child: Text(
                        data[index].label,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxY * 1.2), // ✅ Padding to prevent clipping top bar
        ),
      ),
    );
  }
}