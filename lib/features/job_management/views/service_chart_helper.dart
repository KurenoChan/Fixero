import 'package:fixero/utils/formatters/formatter.dart';

import '../models/job.dart';
import 'service_chart_data.dart';

List<ServiceChartData> aggregateServicePopularity(List<Job> jobs) {
  final Map<String, double> serviceTotals = {};

  for (var job in jobs) {
    final rawServiceType = job.jobServiceType.trim();
    if (rawServiceType.isEmpty) continue;

    final normalized = rawServiceType.toLowerCase(); // normalize for counting
    serviceTotals[normalized] = (serviceTotals[normalized] ?? 0) + 1;
  }

  // Convert to chart data with capitalized labels
  return serviceTotals.entries
      .map(
        (e) => ServiceChartData(
          label: Formatter.capitalize(e.key), // display nicely
          value: e.value,
        ),
      )
      .toList();
}
