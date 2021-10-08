import 'dart:convert';

import '../api/api_util.dart';
import 'AuthController.dart';
import '../models/AdBanner.dart';
import '../models/MyResponse.dart';
import '../services/Network.dart';
import '../utils/InternetUtils.dart';

class AdBannerController {
  //------------------------ Get all categories -----------------------------------------//
  static Future<MyResponse<List<AdBanner>>> getAllBanner() async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.BANNERS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<AdBanner>>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<List<AdBanner>> myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        List<AdBanner> list =
            AdBanner.getListFromJson(json.decode(response.body!));
        myResponse.success = true;
        myResponse.data = list;
      } else {
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<List<AdBanner>>();
    }
  }
}
