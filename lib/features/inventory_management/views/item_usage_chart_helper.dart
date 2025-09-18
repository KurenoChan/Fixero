import '../models/item_usage.dart';
import 'item_usage_chart_data.dart';
import 'package:intl/intl.dart';

/// Aggregates item usage by month for charting
List<ItemUsageChartData> aggregateItemUsageByMonth(List<ItemUsage> usages) {
  // Map of month abbreviation to total quantity
  final Map<String, double> monthlyTotals = {};

  for (var usage in usages) {
    final date = DateTime.tryParse(usage.usageDate);
    if (date == null) continue;

    final monthLabel = DateFormat('MMM').format(date); // e.g., Jan, Feb
    final quantity = usage.quantityUsed?.toDouble() ?? 0;

    monthlyTotals[monthLabel] = (monthlyTotals[monthLabel] ?? 0) + quantity;
  }

  // Sort months in calendar order
  final monthOrder = [
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
    'Dec',
  ];

  return monthOrder
      .where((m) => monthlyTotals.containsKey(m))
      .map((m) => ItemUsageChartData(label: m, value: monthlyTotals[m]!))
      .toList();
}
