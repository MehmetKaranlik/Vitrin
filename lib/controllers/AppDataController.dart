
import 'dart:convert';

import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/models/AppData.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/services/Network.dart';
import 'package:vitrinint/utils/InternetUtils.dart';

import 'AuthController.dart';

class AppDataController {
  static String appdata = "appdata";

  //------------------------ Get single shop -----------------------------------------//
  static Future<MyResponse<Map<String, dynamic>>> getAppData() async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String? url = ApiUtil.MAIN_API_URL + ApiUtil.APP_DATA;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<Map<String, dynamic>>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<Map<String, dynamic>> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
        dynamic decodedData = json.decode(response.body!);
        Map<String, dynamic> data = {
          appdata: AppData.getListFromJson(decodedData),
        };
        myResponse.data = data;
      } else {
        myResponse.success = false;
        myResponse.setError(json.decode(response.body!));
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<Map<String, dynamic>>();
    }
  }
}

