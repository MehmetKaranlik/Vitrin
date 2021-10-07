import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/models/AdBanner.dart';
import 'package:vitrinint/models/Category.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/models/Shop.dart';
import 'package:vitrinint/models/Stories.dart';
import 'package:vitrinint/services/Network.dart';
import 'package:vitrinint/utils/InternetUtils.dart';

import 'AuthController.dart';

class HomeFilterController {
  static String shops = "shops";
  //------------------------ Get all shop -----------------------------------------//
  static Future<MyResponse<Map<String, dynamic>>> getAllShops() async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String? url = ApiUtil.MAIN_API_URL + ApiUtil.SHOPS;
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
          shops: Shop.getListFromJson(decodedData),
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
