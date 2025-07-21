import '../model/chart_datamodel.dart';

class ServiceData implements ChartDataModel {
  final String serviceName;
  final double percentage;

  ServiceData(this.serviceName, this.percentage);

  @override
  // TODO: implement label
  String get label => serviceName;

  @override
  // TODO: implement value
  double get value => percentage;
}

class ServiceDAO {
  static List<ServiceData> initializeData() {
    return [
      ServiceData("Oil Change", 35),
      ServiceData("Brake", 25),
      ServiceData("Battery", 20),
      ServiceData("Alignment", 20),
    ];
  }
}