import 'dart:convert';

import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/models/Favorite.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/services/Network.dart';
import 'package:vitrinint/utils/InternetUtils.dart';

import 'AuthController.dart';

class FavoriteController{


  //------------------------ Toggle favorite ----------------------------------------//
  static Future<MyResponse> toggleFavorite(int productId) async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.FAVORITES;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body data
    Map data = {
      'product_id': productId,
    };

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.post(
          url, headers: headers, body: body);
      MyResponse<dynamic> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
        myResponse.data = json.decode(response.body!);
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError();
    }
  }


  //------------------------ Get all orders  -----------------------------------------//
  static Future<MyResponse<List<Favorite>>> getAllFavorite() async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.FAVORITES;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Favorite>>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<List<Favorite>> myResponse = MyResponse(response.statusCode);

      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
        myResponse.data = Favorite.getListFromJson(json.decode(response.body!));
      } else {
        Map<String, dynamic> data = json.decode(response.body!);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<List<Favorite>>();
    }

  }
}