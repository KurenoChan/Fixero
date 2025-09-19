import 'package:intl/intl.dart';
import '../models/job.dart';
import 'job_demand_chart_data.dart';

List<JobDemandChartData> aggregateJobDemandByMonth(List<Job> jobs) {
  final Map<String, double> monthlyTotals = {};

  for (var job in jobs) {
    final createdAt = DateTime.tryParse(
      job.createdAt,
    ); // assuming this is DateTime
    if (createdAt == null) continue;

    final monthLabel = DateFormat('MMM').format(createdAt); // Jan, Feb...
    monthlyTotals[monthLabel] = (monthlyTotals[monthLabel] ?? 0) + 1;
  }

  // keep months in calendar order
  const monthOrder = [
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
      .map((m) => JobDemandChartData(label: m, value: monthlyTotals[m]!))
      .toList();
}

String getJobDemandTrend(List<JobDemandChartData> demand) {
  if (demand.length < 2) return "0%";

  final last = demand[demand.length - 1].value;
  final prev = demand[demand.length - 2].value;

  if (prev == 0) return "+100%";
  final diff = ((last - prev) / prev * 100).toStringAsFixed(1);
  return "${last >= prev ? "+" : ""}$diff%";
}
