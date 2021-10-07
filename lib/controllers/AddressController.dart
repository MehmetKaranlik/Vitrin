import 'dart:convert';
import 'dart:developer';

import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/models/UserAddress.dart';
import 'package:vitrinint/services/Network.dart';
import 'package:vitrinint/utils/InternetUtils.dart';

import 'AuthController.dart';

class AddressController {

  //-------------------- Add user address --------------------------------//
  static Future<MyResponse> addAddress(
      {double? latitude,
      double? longitude,
      String? address,
      String? address2,
      String? city,
      int? pincode,
      int? type}) async {
    //Get Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ADDRESSES;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body Data
    Map data = {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'address2': address2,
      'city': city,
      'pincode': pincode,
      'type': type ?? UserAddress.OTHER
    };

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if(!isConnected){
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.post(
          url, headers: headers, body: body);
      MyResponse myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
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


  //-------------------- Get all address for currently login user --------------------------------//
  static Future<MyResponse<List<UserAddress>>> getMyAddresses() async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ADDRESSES;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<UserAddress>>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);

      MyResponse<List<UserAddress>> myResponse = MyResponse(
          response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
        myResponse.data =
            UserAddress.getListFromJson(json.decode(response.body!));
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<List<UserAddress>>();
    }
  }


  //-------------------- Delete user address --------------------------------//
  static Future<MyResponse> updateAddress(int addressId,
      {bool? isDefault,
      double? latitude,
      double? longitude,
      String? address,
      String? address2,
      String? city,
      int? pincode,
      int? type}) async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url =
        ApiUtil.MAIN_API_URL + ApiUtil.ADDRESSES + addressId.toString();

    //Body Data
    Map data = {};
    if (isDefault != null) {
      data['default'] = isDefault;
    }
    if (latitude != null) {
      data['latitude'] = latitude;
    }
    if (longitude != null) {
      data['longitude'] = longitude;
    }

    if (address != null) {
      data['address'] = address;
    }
    if (address2 != null) {
      data['address2'] = address2 + "";
    }
    if (city != null) {
      data['city'] = city;
    }
    if (pincode != null) {
      data['pincode'] = pincode;
    }
    if (type != null) {
      data['type'] = type;
    }

    //Encode
    String body = json.encode(data);

    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    log(body);

    try {
      NetworkResponse response =
          await Network.post(url, headers: headers, body: body);

      log(response.body.toString());

      MyResponse myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      log(e.toString());
      return MyResponse.makeServerProblemError();
    }
  }

  //-------------------- Delete user address --------------------------------//
  static Future<MyResponse> deleteAddress(int addressId) async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url =
        ApiUtil.MAIN_API_URL + ApiUtil.ADDRESSES + addressId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.delete(url, headers: headers);
      MyResponse myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
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
