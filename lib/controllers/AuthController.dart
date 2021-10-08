import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../api/api_util.dart';
import '../models/Account.dart';
import '../models/MyResponse.dart';
import '../models/User.dart';
import '../services/Network.dart';
import '../services/PushNotificationsManager.dart';
import '../utils/InternetUtils.dart';
import '../utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppTheme.dart';

enum AuthType { VERIFIED, LOGIN, NOT_FOUND, BLOCKED }

class AuthController {
  //--------------------- Log In ---------------------------------------------//
  static Future<MyResponse> loginUser(String email, String password) async {
    //Get FCM

    PushNotificationsManager pushNotificationsManager =
        PushNotificationsManager.instance;

    pushNotificationsManager = PushNotificationsManager();
    pushNotificationsManager.init();

    //await pushNotificationsManager.init();
    String? fcmToken = await pushNotificationsManager.getToken();

    //URL
    String loginUrl = ApiUtil.MAIN_API_URL + ApiUtil.AUTH_LOGIN;

    //Body Data
    Map data = {'email': email, 'password': password, 'fcm_token': fcmToken};

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    //Response
    try {
      NetworkResponse response = await Network.post(loginUrl,
          headers: ApiUtil.getHeader(requestType: RequestType.Post),
          body: body);

      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();

        Map<String, dynamic> data = json.decode(response.body!);
        Map<String, dynamic> user = data['user'];
        String token = data['token'];

        await saveUser(user);

        await sharedPreferences.setString('token', token);

        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }

      return myResponse;
    } catch (e) {
      log(e.toString());
      return MyResponse.makeServerProblemError();
    }
  }

  //--------------------- Check Mobile Availability ---------------------------------------------//
  static Future<MyResponse> mobileVerified(String? mobileNumber) async {
    //Get Token
    String? token = await AuthController.getApiToken();

    //URL
    String url = ApiUtil.MAIN_API_URL + ApiUtil.AUTH_MOBILE_VERIFIED;

    //Body Data
    Map data = {'mobile': mobileNumber};

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    //Response
    try {
      NetworkResponse response = await Network.post(url,
          headers: ApiUtil.getHeader(
              requestType: RequestType.PostWithAuth, token: token),
          body: body);

      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body!);
        Map<String, dynamic> user = data['user'];

        await saveUser(user);

        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      return MyResponse.makeServerProblemError();
    }
  }

  //--------------------- Mobile Verified ---------------------------------------------//
  static Future<MyResponse> verifyMobileNumber(String mobileNumber) async {
    //Get Token
    String? token = await AuthController.getApiToken();

    //URL
    String url = ApiUtil.MAIN_API_URL + ApiUtil.MOBILE_NUMBER_VERIFY;

    //Body Data
    Map data = {'mobile': mobileNumber};

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    //Response
    try {
      NetworkResponse response = await Network.post(url,
          headers: ApiUtil.getHeader(
              requestType: RequestType.PostWithAuth, token: token),
          body: body);

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
      return MyResponse.makeServerProblemError();
    }
  }

  //--------------------- Register  ---------------------------------------------//
  static Future<MyResponse> registerUser(
      String name, String email, String password) async {
    //Add FCM Token
    PushNotificationsManager pushNotificationsManager =
        PushNotificationsManager();
    await pushNotificationsManager.init();
    String? fcmToken = await pushNotificationsManager.getToken();

    //URL
    String registerUrl = ApiUtil.MAIN_API_URL + ApiUtil.AUTH_REGISTER;

    //Body
    Map data = {
      'name': name,
      'email': email,
      'password': password,
      'fcm_token': fcmToken
    };

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    //Response
    try {
      NetworkResponse response = await Network.post(registerUrl,
          headers: ApiUtil.getHeader(requestType: RequestType.Post),
          body: body);

      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();

        Map<String, dynamic> data = json.decode(response.body!);
        Map<String, dynamic> user = data['user'];
        String token = data['token'];

        await sharedPreferences.setString('name', user['name']);
        await sharedPreferences.setString('email', user['email']);
        await sharedPreferences.setString(
            'avatar_url', user['avatar_url'] ?? "");
        await sharedPreferences.setString('token', token);
        await sharedPreferences.setBool('mobile_verified', false);

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

  //--------------------- Forgot Password ---------------------------------------------//
  static Future<MyResponse> forgotPassword(String email) async {
    String url = ApiUtil.MAIN_API_URL + ApiUtil.FORGOT_PASSWORD;

    //Body date
    Map data = {'email': email};

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.post(url,
          headers: ApiUtil.getHeader(requestType: RequestType.Post),
          body: body);

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
      return MyResponse.makeServerProblemError();
    }
  }

  //---------------------- Update user ------------------------------------------//
  static Future<MyResponse> updateUser(String password, File? imageFile) async {
    //Get Token
    String? token = await AuthController.getApiToken();
    String registerUrl = ApiUtil.MAIN_API_URL + ApiUtil.UPDATE_PROFILE;

    Map data = {};

    if (password.isNotEmpty) data['password'] = password;

    if (imageFile != null) {
      final bytes = imageFile.readAsBytesSync();
      String img64 = base64Encode(bytes);
      data['avatar_image'] = img64;
    }

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.post(
        registerUrl,
        headers: ApiUtil.getHeader(
            requestType: RequestType.PostWithAuth, token: token),
        body: body,
      );

      MyResponse myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body!);
        await saveUser(data['user']);
        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }

      return myResponse;
    } catch (e) {
      return MyResponse.makeServerProblemError();
    }
  }

  //------------------------ Logout -----------------------------------------//
  static Future<bool> logoutUser() async {
    //Remove FCM Token
    PushNotificationsManager pushNotificationsManager =
        PushNotificationsManager();
    await pushNotificationsManager.removeFCM();

    //Clear all Data
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences.remove('name');
    await sharedPreferences.remove('email');
    await sharedPreferences.remove('avatar_url');
    await sharedPreferences.remove('token');
    await sharedPreferences.remove('mobile');
    await sharedPreferences.remove('mobile_verified');
    await sharedPreferences.remove('blocked');

    return true;
  }

  //------------------------ Save user in cache -----------------------------------------//
  static saveUser(Map<String, dynamic> user) async {
    await saveUserFromUser(User.fromJson(user));
  }

  static saveUserFromUser(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('name', user.name!);
    await sharedPreferences.setString('email', user.email!);
    await sharedPreferences.setBool('mobile_verified', user.mobileVerified);
    await sharedPreferences.setString('avatar_url', user.avatarUrl!);
    await sharedPreferences.setString('mobile', user.mobile!);
    await sharedPreferences.setBool('blocked', user.blocked);
  }

  //------------------------ Get user from cache -----------------------------------------//
  static Future<Account> getAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? name = sharedPreferences.getString('name');
    String? email = sharedPreferences.getString('email');
    String? token = sharedPreferences.getString('token');
    String? avatarUrl = sharedPreferences.getString('avatar_url');

    return Account(name, email, token, avatarUrl);
  }

  //------------------------ Check user logged in or not -----------------------------------------//
  static Future<AuthType> userAuthType() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      String? token = sharedPreferences.getString("token");
      bool mobileVerified =
          sharedPreferences.getBool('mobile_verified') ?? false;
      bool blocked = sharedPreferences.getBool('blocked') ?? false;
      if (blocked) {
        return AuthType.BLOCKED;
      }
      if (token == null) {
        return AuthType.NOT_FOUND;
      } else if (!mobileVerified) {
        return AuthType.LOGIN;
      }
      return AuthType.VERIFIED;
    } catch (e) {}
    return AuthType.NOT_FOUND;
  }

  //------------------------ Get api token -----------------------------------------//
  static Future<String?> getApiToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("token");
  }

  //------------------------ Testing notice -------------------------------------//

  static Widget notice(ThemeData themeData) {
    return Container(
      margin: Spacing.fromLTRB(24, 36, 24, 24),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: "Note: ",
              style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                  color: Colors.purple, fontWeight: 600)),
          TextSpan(
              text:
                  "After testing please logout, because there is many user testing with same IDs so it can be possible that you can get unnecessary notifications",
              style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 500,
                  letterSpacing: 0)),
        ]),
      ),
    );
  }
}
