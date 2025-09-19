import '../models/item_usage.dart';
import 'item_usage_chart_data.dart';
import 'package:intl/intl.dart';

/// Aggregates item usage by month (grouped by year+month) for charting
List<ItemUsageChartData> aggregateItemUsageByMonth(List<ItemUsage> usages) {
  // Map of "yyyy-MM" -> total quantity OR count
  final Map<String, double> monthlyTotals = {};

  for (var usage in usages) {
    final date = DateTime.tryParse(usage.usageDate);
    if (date == null) continue;

    final key = DateFormat('yyyy-MM').format(date);
    final quantity = usage.quantityUsed?.toDouble() ?? 0;

    if (quantity > 0) {
      // Normal case: sum the quantity
      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + quantity;
    } else {
      // Quantity is 0, count the usage record instead
      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + 1;
    }
  }

  // Sort by year-month
  final sortedKeys = monthlyTotals.keys.toList()
    ..sort((a, b) => a.compareTo(b));

  return sortedKeys.map((key) {
    final date = DateFormat('yyyy-MM').parse(key);
    final monthLabel = DateFormat('MMM').format(date); // e.g., Jan
    return ItemUsageChartData(label: monthLabel, value: monthlyTotals[key]!);
  }).toList();
}
