import 'dart:ui';

import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/controllers/AuthController.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/utils/SizeConfig.dart';
import 'package:vitrinint/utils/TextUtils.dart';
import 'package:vitrinint/views/auth/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../AppScreen.dart';

class OTPVerificationScreen extends StatefulWidget {
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late ThemeData themeData;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  TextEditingController? _numberController;
  TextEditingController? _otpController;
  FocusNode otpFN = FocusNode();

  bool isInProgress = false;
  String? _verificationId;

  final GlobalKey _countryCodeSelectionKey = new GlobalKey();
  int selectedCountryCode = 0;
  List<PopupMenuEntry<Object>>? countryList;
  List<dynamic> countryCode = TextUtils.countryCode;

  List<bool> _dataExpansionPanel = [true, false];

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController();
    _otpController = TextEditingController();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      showMessage(message: "Please verify your phone number");
    });
  }

  @override
  void dispose() {
    super.dispose();
    _numberController!.dispose();
  }

  Future<void> sendOTP() async {
    String? phoneNumber = getNumberWithFormat();
    if (phoneNumber == null) {
      return;
    }
    setState(() {
      isInProgress = true;
    });

    MyResponse myResponse =
    await AuthController.verifyMobileNumber(phoneNumber);

    ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
    if (!myResponse.success) {
      showMessage(message: "This is used phone number ");
      setState(() {
        isInProgress = false;
      });
      return;
    }

    await Firebase.initializeApp();

    print(phoneNumber);

    void verificationCompleted(AuthCredential phoneAuthCredential) {
      verifiedComplete(phoneNumber);
    }

    void verificationFailed(FirebaseAuthException error) {
      if (error.code == 'invalid-phone-number') {
        showMessage(message: "Please use [country code] then [number] format");
      }
      showMessage(message: error.code);
    }

    void codeSent(String verificationId, [int? code]) {
      setState(() {
        _dataExpansionPanel[1] = true;
        otpFN.requestFocus();
      });
      _verificationId = verificationId;
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      print('codeAutoRetrievalTimeout');
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(milliseconds: 10000),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  getNumberWithFormat() {
    String number = _numberController!.text.trim();

    if (number.contains("+")) {
      showMessage(message: "Please enter number properly");
      return null;
    }

    if (number.length < 6) {
      showMessage(message: "Please enter number properly");
      return null;
    }

    return countryCode[selectedCountryCode]['code'] + number;
  }

  onOTPVerify() async {
    String? number = getNumberWithFormat();
    String otp = _otpController!.text.trim();
    if (otp.isEmpty) {
      showMessage(message: "Please fill OTP");
    } else if (otp.length != 6) {
      showMessage(message: "Your OTP is not 6 digit");
    } else {
      try {
        PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
        verifiedComplete(number);
      } catch (e) {
        showMessage(message: "Your verification code is wrong");
      }
    }
  }

  verifiedComplete(String? number) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    try {
      MyResponse response = await AuthController.mobileVerified(number);

      AuthType authType = await AuthController.userAuthType();

      if (mounted) {
        setState(() {
          isInProgress = false;
        });
      }

      if (authType == AuthType.VERIFIED) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AppScreen(),
          ),
        );
      } else if (authType == AuthType.LOGIN) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => OTPVerificationScreen(),
          ),
        );
      } else {
        ApiUtil.checkRedirectNavigation(context, response.responseCode);
        showMessage(message: response.errorText);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        return MaterialApp(
            scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  centerTitle: true,
                  title: Text("OTP Verification",
                      style: themeData.appBarTheme.textTheme!.headline6),
                ),
                body: Container(
                  margin: Spacing.all(16),
                  child: Column(
                    children: [
                      Container(
                        height: MySize.size3,
                        child: isInProgress
                            ? LinearProgressIndicator(
                          minHeight: MySize.size3,
                        )
                            : Container(
                          height: MySize.size3,
                        ),
                      ),
                      ExpansionPanelList(
                        expandedHeaderPadding: Spacing.zero as EdgeInsets,
                        expansionCallback: (int index, bool isExpanded) {
                          setState(() {
                            _dataExpansionPanel[index] = !isExpanded;
                          });
                        },
                        animationDuration: Duration(milliseconds: 500),
                        children: <ExpansionPanel>[
                          ExpansionPanel(
                              canTapOnHeader: true,
                              headerBuilder:
                                  (BuildContext context, bool isExpanded) {
                                return Container(
                                    padding: Spacing.all(16),
                                    child: Text("Number",
                                        style: AppTheme.getTextStyle(
                                            themeData.textTheme.subtitle1,
                                            fontWeight:
                                            isExpanded ? 600 : 400)));
                              },
                              body: Container(
                                padding: Spacing.all(16),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: themeData
                                                  .colorScheme.background,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          padding:
                                              Spacing.fromLTRB(8, 12, 8, 12),
                                          child: PopupMenuButton(
                                            key: _countryCodeSelectionKey,
                                            child: InkWell(
                                                onTap: () {
                                                  dynamic state =
                                                      _countryCodeSelectionKey
                                                          .currentState;
                                                  state.showButtonMenu();
                                                },
                                                child: Text(countryCode[
                                                        selectedCountryCode]
                                                    ['code'])),
                                            onSelected: (dynamic value) {
                                              setState(() {
                                                selectedCountryCode = value;
                                              });
                                            },
                                            itemBuilder:
                                                (BuildContext context) {
                                              return getCountryList();
                                            },
                                            color: themeData.backgroundColor,
                                          ),
                                        ),
                                        Spacing.width(8),
                                        Expanded(
                                          child: TextFormField(
                                            style: AppTheme.getTextStyle(
                                                themeData.textTheme.bodyText1,
                                                letterSpacing: 0.1,
                                                color: themeData
                                                    .colorScheme.onBackground,
                                                fontWeight: 500),
                                            decoration: InputDecoration(
                                                prefixStyle:
                                                    AppTheme.getTextStyle(
                                                        themeData.textTheme
                                                            .subtitle2,
                                                        letterSpacing: 0.1,
                                                        color: themeData
                                                            .colorScheme
                                                            .onBackground,
                                                        fontWeight: 500),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    borderSide: BorderSide
                                                        .none),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(8.0),
                                                        ),
                                                        borderSide:
                                                            BorderSide.none),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(8.0),
                                                        ),
                                                        borderSide:
                                                            BorderSide.none),
                                                filled: true,
                                                fillColor: themeData
                                                    .colorScheme.background,
                                                isDense: true,
                                                contentPadding:
                                                    Spacing.fromLTRB(
                                                        16, 20, 20, 0)),
                                            keyboardType: TextInputType.number,
                                            autofocus: true,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller: _numberController,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacing.height(16),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                          style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all(
                                                      Spacing.xy(16, 0))),
                                          onPressed: isInProgress
                                              ? null
                                              : () {
                                            sendOTP();
                                          },
                                          child: Text("Send OTP",
                                              style: AppTheme.getTextStyle(
                                                  themeData.textTheme.bodyText2,
                                                  fontWeight: 600,
                                                  color: themeData
                                                      .colorScheme.onPrimary))),
                                    )
                                  ],
                                ),
                              ),
                              isExpanded: _dataExpansionPanel[0]),
                          ExpansionPanel(
                              canTapOnHeader: true,
                              headerBuilder:
                                  (BuildContext context, bool isExpanded) {
                                return Container(
                                    padding: Spacing.all(16),
                                    child: Text("OTP",
                                        style: AppTheme.getTextStyle(
                                            themeData.textTheme.subtitle1,
                                            fontWeight:
                                            isExpanded ? 600 : 500)));
                              },
                              body: Container(
                                  padding: Spacing.only(bottom: 16, top: 8),
                                  child: Container(
                                    padding: Spacing.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: <Widget>[
                                        TextFormField(
                                          style: AppTheme.getTextStyle(
                                              themeData.textTheme.bodyText1,
                                              letterSpacing: 0.1,
                                              color: themeData
                                                  .colorScheme.onBackground,
                                              fontWeight: 500),
                                          decoration: InputDecoration(
                                            prefixStyle: AppTheme.getTextStyle(
                                                themeData.textTheme.subtitle2,
                                                letterSpacing: 0.1,
                                                color: themeData
                                                    .colorScheme.onBackground,
                                                fontWeight: 500),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0),
                                                ),
                                                borderSide: BorderSide.none),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0),
                                                ),
                                                borderSide: BorderSide.none),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0),
                                                ),
                                                borderSide: BorderSide.none),
                                            filled: true,
                                            fillColor: themeData
                                                .colorScheme.background,
                                            prefixIcon: Icon(
                                              MdiIcons.numeric,
                                              size: 22,
                                              color: themeData
                                                  .colorScheme.onBackground
                                                  .withAlpha(200),
                                            ),
                                            isDense: true,
                                            contentPadding: Spacing.zero,
                                          ),
                                          focusNode: otpFN,
                                          controller: _otpController,
                                          keyboardType: TextInputType.number,
                                          autofocus: true,
                                          textCapitalization:
                                          TextCapitalization.sentences,
                                        ),
                                        Spacing.height(16),
                                        Container(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                  padding:
                                                  MaterialStateProperty.all(
                                                      Spacing.xy(16, 0))),
                                              onPressed: _verificationId == null
                                                  ? null
                                                  : () {
                                                onOTPVerify();
                                              },
                                              child: Text("Verify",
                                                  style: AppTheme.getTextStyle(
                                                      themeData
                                                          .textTheme.bodyText2,
                                                      fontWeight: 600,
                                                      color: themeData
                                                          .colorScheme
                                                          .onPrimary))),
                                        ),
                                      ],
                                    ),
                                  )),
                              isExpanded: _dataExpansionPanel[1])
                        ],
                      ),
                      Spacing.height(16),
                      Center(
                        child: ElevatedButton(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    Spacing.xy(16, 0))),
                            onPressed: () async {
                              await AuthController.logoutUser();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginScreen(),
                                ),
                              );
                            },
                            child: Text("Logout",
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    fontWeight: 600,
                                    color: themeData.colorScheme.onPrimary))),
                      )
                    ],
                  ),
                )));
      },
    );
  }

  void showMessage({String message = "Something wrong", Duration? duration}) {
    if (duration == null) {
      duration = Duration(seconds: 3);
    }
    _scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        duration: duration,
        content: Text(message,
            style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                letterSpacing: 0.4, color: themeData.colorScheme.onPrimary)),
        backgroundColor: themeData.colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  List<PopupMenuEntry<Object>> getCountryList() {
    if (countryList != null) return countryList!;
    countryList = <PopupMenuEntry<Object>>[];
    for (int i = 0; i < countryCode.length; i++) {
      countryList!.add(PopupMenuItem(
        value: i,
        child: Container(
          margin: Spacing.vertical(2),
          child: Text(
              countryCode[i]['name'] + " ( " + countryCode[i]['code'] + " )",
              style: AppTheme.getTextStyle(
                themeData.textTheme.subtitle2,
                color: themeData.colorScheme.onBackground,
              )),
        ),
      ));
      countryList!.add(
        PopupMenuDivider(
          height: 10,
        ),
      );
    }
    return countryList!;
  }
}
