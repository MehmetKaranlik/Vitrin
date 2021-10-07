
import 'User.dart';

class AppData {

  int id;
  int applicationMinimumVersion;
  String supportPayments;
  String mainColor;
  String secondColor;

  AppData(this.id, this.applicationMinimumVersion, this.supportPayments,this.mainColor,this.secondColor);

  static fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int applicationMinimumVersion = int.parse(jsonObject['application_minimum_version'].toString());
    String supportPayments = jsonObject['support_payments'].toString();
    String mainColor = jsonObject['main_color'].toString();
    String secondColor = jsonObject['second_color'].toString();

    return AppData(id,applicationMinimumVersion, supportPayments,mainColor,secondColor);
  }

  static List<AppData> getListFromJson(List<dynamic> jsonArray) {
    List<AppData> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(AppData.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'AppData{id: $id, applicationMinimumVersion: $applicationMinimumVersion, supportPayments: $supportPayments,mainColor:$mainColor,secondColor:$secondColor}';
  }
}