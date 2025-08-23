
import '../../common/models/chart_datamodel.dart';

class IncomeData implements ChartDataModel {
  final String month;
  final double amount;

  IncomeData(this.month, this.amount);

  @override
  // TODO: implement label
  String get label => month;

  @override
  // TODO: implement value
  double get value => amount;
}

class IncomeDAO {
  static List<IncomeData> initializeData() {
    return [
      IncomeData('Jan', 1200),
      IncomeData('Feb', 1800),
      IncomeData('Mar', 1400),
      IncomeData('Apr', 2000),
      IncomeData('May', 1700),
      IncomeData('Jun', 1800),
      IncomeData('Jul', 1230),
      IncomeData('Aug', 1140),
      IncomeData('Sep', 920),
      IncomeData('Oct', 840),
      IncomeData('Nov', 1050),
      IncomeData('Dec', 1720),
    ];
  }
}