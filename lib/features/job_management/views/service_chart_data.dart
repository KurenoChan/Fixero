import '../../../common/models/chart_datamodel.dart';

class ServiceChartData extends ChartDataModel {
  @override
  final String label; // Service type (e.g., Oil Change, Battery Check)
  @override
  final double value; // Count of jobs of that type

  ServiceChartData({
    required this.label,
    required this.value,
  });
}
