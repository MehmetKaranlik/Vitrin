import 'dart:convert';

import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/models/Cart.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/services/Network.dart';
import 'package:vitrinint/utils/InternetUtils.dart';

import 'AuthController.dart';

class CartController {


  //------------------------ Add into cart -----------------------------------------//
  static Future<MyResponse> addIntoCart(int productId,int productItemId,
      {int quantity = 1}) async {

  //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.CARTS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Make body options
    Map data = {
      'product_id': productId,
      'product_item_id': productItemId,
      'quantity': quantity,
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
      MyResponse myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
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


  //------------------------ Get all cart product -----------------------------------------//
  static Future<MyResponse<List<Cart>>> getAllCartProduct() async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.CARTS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);


      MyResponse<List<Cart>> myResponse = MyResponse(response.statusCode);


      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
        myResponse.data = Cart.getListFromJson(json.decode(response.body!));
      } else {
        myResponse.success = false;
        myResponse.setError(json.decode(response.body!));
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<List<Cart>>();
    }
  }


  //------------------------ Change cart quantity -----------------------------------------//
  static Future<MyResponse> changeCartQuantity(int cartId,int quantity) async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.CARTS + cartId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body data
    Map data = ApiUtil.getPatchRequestBody();
    data['quantity'] = quantity.toString();

    //Encoded
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.post(
          url, headers: headers, body: body);
      MyResponse myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
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


  //------------------------ Delete cart -----------------------------------------//
  static Future<MyResponse> deleteCart(int cartId) async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.CARTS + cartId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.delete(
          url, headers: headers);
      MyResponse myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
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
}
