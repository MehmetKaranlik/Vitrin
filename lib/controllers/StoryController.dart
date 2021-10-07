import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/models/Category.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/models/Shop.dart';
import 'package:vitrinint/models/Stories.dart';
import 'package:vitrinint/services/Network.dart';
import 'package:vitrinint/utils/InternetUtils.dart';

import 'AuthController.dart';

class StoryController {
  static String stories = "stories";

  //------------------------ Get single shop -----------------------------------------//
  static Future<MyResponse<Map<String, dynamic>>> getStoryData(
      int? shopId) async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String singleShopUrl =
        ApiUtil.MAIN_API_URL + ApiUtil.STORIES_ALL + shopId.toString();

    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);
    /*print(
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token));*/

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<Map<String, dynamic>>();
    }

    try {
      Uri parsedUrl = Uri.parse(singleShopUrl);
      Response response = await http.get(parsedUrl, headers: headers);
      MyResponse<Map<String, dynamic>> myResponse =
          MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode)) {
        myResponse.success = true;
        // print("Response Body:" + response.body);
        dynamic decodedData = json.decode(response.body);
        Map<String, dynamic> data = {
          stories: Stories.getListFromJson(decodedData),
        };
        myResponse.data = data;
      } else {
        myResponse.success = false;
        myResponse.setError(json.decode(response.body));
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<Map<String, dynamic>>();
    }
  }
}
