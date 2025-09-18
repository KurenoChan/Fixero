import '../../../common/models/chart_datamodel.dart';

class ItemUsageChartData extends ChartDataModel {
  @override
  final String label; // Month abbreviation, e.g., "Jan"
  @override
  final double value; // Quantity used

  ItemUsageChartData({
    required this.label,
    required this.value,
  });
}
