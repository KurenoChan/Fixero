import '../../../common/models/chart_datamodel.dart';

class JobDemandChartData extends ChartDataModel {
  @override
  final String label; // Month abbreviation, e.g. "Jan"
  @override
  final double value; // Total jobs created in that month

  JobDemandChartData({
    required this.label,
    required this.value,
  });
}
