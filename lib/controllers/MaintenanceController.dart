import 'dart:convert';

import '../api/api_util.dart';
import '../models/MyResponse.dart';
import '../services/Network.dart';
import '../utils/InternetUtils.dart';

class MaintenanceController {
  //------------------------ Checking maintenance  -----------------------------------------//
  static Future<MyResponse> checkMaintenance() async {
    String maintenanceUrl = ApiUtil.MAIN_API_URL + ApiUtil.MAINTENANCE;

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.get(maintenanceUrl,
          headers: ApiUtil.getHeader(requestType: RequestType.Post));

      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError();
    }
  }
}
