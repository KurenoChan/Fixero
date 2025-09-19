import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/chart_datamodel.dart';

class FixeroLineChart<T extends ChartDataModel> extends StatelessWidget {
  final List<T> data;
  final Color color;
  final bool showDot;
  final bool showGradient;

  const FixeroLineChart({
    super.key,
    required this.data,
    this.color = Colors.blue,
    this.showDot = false,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.any((d) => !d.value.isFinite)) {
      return const Center(
        child: Text(
          "( No record )",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minY = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final intervalY = ((maxY - minY) / 4).ceilToDouble();

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: (maxY * 1.1), // 10% padding on top
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                dotData: FlDotData(
                  show: showDot,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: 4, // dot size
                        color: color, // dot fill color
                        strokeWidth: 1.5,
                        strokeColor: Theme.of(
                          context,
                        ).colorScheme.primary, // optional border
                      ),
                ),
                color: color,
                belowBarData: BarAreaData(
                  show: showGradient,
                  gradient: LinearGradient(
                    colors: [color.withAlpha(30), color.withAlpha(0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],

            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (LineBarSpot touchedSpot) {
                  return Theme.of(context).colorScheme.primary;
                },
                tooltipBorderRadius: BorderRadius.circular(5),
                fitInsideHorizontally:
                    true, // <-- Fit tooltip inside horizontally
                fitInsideVertically: true, // <-- Fit tooltip inside vertically
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    final label = data[touchedSpot.spotIndex].label;
                    final value = touchedSpot.y.toStringAsFixed(0);
                    return LineTooltipItem(
                      '$label\n$value',
                      const TextStyle(color: Colors.white),
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: intervalY > 0 ? intervalY : 500,
                  reservedSize: 40,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  reservedSize: 40, // more space below to prevent cutoff
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data[index].label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
          ),
        ),
      ),
    );
  }
}
