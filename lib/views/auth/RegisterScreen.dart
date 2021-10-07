
import 'package:hexcolor/hexcolor.dart';
import 'package:vitrinint/AppTheme.dart';
import 'package:vitrinint/AppThemeNotifier.dart';
import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/controllers/AppDataController.dart';
import 'package:vitrinint/controllers/AuthController.dart';
import 'package:vitrinint/models/AppData.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/services/AppLocalizations.dart';
import 'package:vitrinint/utils/SizeConfig.dart';
import 'package:vitrinint/utils/Validator.dart';
import 'package:vitrinint/views/AppScreen.dart';
import 'package:vitrinint/views/auth/LoginScreen.dart';
import 'package:vitrinint/widgets/FlutButton.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'OTPVerificationScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //Theme Data
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  //Text Field Editing Controller
  TextEditingController? nameTFController;
  TextEditingController? emailTFController;
  TextEditingController? passwordTFController;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  //Other Variables
  bool isInProgress = false;
  bool showPassword = false;

  //UI Variables
  OutlineInputBorder? allTFBorder;
  List<AppData>? appdata;

  @override
  void initState() {
    super.initState();
    getAppData();
    nameTFController = TextEditingController();
    emailTFController = TextEditingController();
    passwordTFController = TextEditingController();
  }

  @override
  void dispose() {
    nameTFController!.dispose();
    emailTFController!.dispose();
    passwordTFController!.dispose();
    super.dispose();
  }

  getAppData() async {
    MyResponse<Map<String, dynamic>> myResponse = await AppDataController.getAppData();
    if (myResponse.data != null) {
      appdata = myResponse.data![AppDataController.appdata];
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }
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

  _handleRegister() async {
    String name = nameTFController!.text;
    String email = emailTFController!.text;
    String password = passwordTFController!.text;

    if (name.isEmpty) {
      showMessage(message: Translator.translate("please_fill_name"));
    } else if (email.isEmpty) {
      showMessage(message: Translator.translate("please_fill_email"));
    } else if (Validator.isEmail(email)) {
      showMessage(message: Translator.translate("please_fill_email_proper"));
    } else if (password.isEmpty) {
      showMessage(message: Translator.translate("please_fill_password"));
    } else {
      if(mounted) {
        setState(() {
          isInProgress = true;
        });
      }

      MyResponse response =
          await AuthController.registerUser(name, email, password);

      if (mounted) {
        setState(() {
          isInProgress = false;
        });
      }

      AuthType authType = await AuthController.userAuthType();

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
    }
  }

  _initUI() {
    allTFBorder = OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(color: customAppTheme.bgLayer4, width: 1.5));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        _initUI();
        return MaterialApp(
            scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(themeType),
            home: Scaffold(
                key: _scaffoldKey,
                body: Container(
                    color: customAppTheme.bgLayer1,
                    child: ListView(
                      padding: Spacing.top(150),
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            './assets/images/shopping.png',
                            color: appdata == null  ? Colors.purple : HexColor(appdata!.first.mainColor),
                            width: 54,
                            height: 54,
                          ),
                        ),
                        Center(
                          child: Container(
                            margin: Spacing.top(24),
                            child: Text(
                              Translator.translate("create_account").toUpperCase(),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.headline6,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 700,
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(24, 24, 24, 0),
                          child: TextFormField(
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                letterSpacing: 0.1,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 500),
                            decoration: InputDecoration(
                                hintText: Translator.translate("name"),
                                hintStyle: AppTheme.getTextStyle(
                                    themeData.textTheme.subtitle2,
                                    letterSpacing: 0.1,
                                    color:
                                    themeData.colorScheme.onBackground,
                                    fontWeight: 500),
                                border: allTFBorder,
                                enabledBorder: allTFBorder,
                                focusedBorder: allTFBorder,
                                prefixIcon: Icon(
                                  MdiIcons.accountOutline,
                                  size: MySize.size22,
                                ),
                                isDense: true,
                                contentPadding: Spacing.zero),
                            keyboardType: TextInputType.text,
                            controller: nameTFController,
                            textCapitalization:
                            TextCapitalization.sentences,
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: TextFormField(
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                letterSpacing: 0.1,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 500),
                            decoration: InputDecoration(
                                hintText: Translator.translate("email_address"),
                                hintStyle: AppTheme.getTextStyle(
                                    themeData.textTheme.subtitle2,
                                    letterSpacing: 0.1,
                                    color:
                                    themeData.colorScheme.onBackground,
                                    fontWeight: 500),
                                border: allTFBorder,
                                enabledBorder: allTFBorder,
                                focusedBorder: allTFBorder,
                                prefixIcon: Icon(
                                  MdiIcons.emailOutline,
                                  size: MySize.size22,
                                ),
                                isDense: true,
                                contentPadding: Spacing.zero),
                            keyboardType: TextInputType.emailAddress,
                            controller: emailTFController,
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: TextFormField(
                            obscureText: showPassword,
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                letterSpacing: 0.1,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 500),
                            decoration: InputDecoration(
                              hintStyle: AppTheme.getTextStyle(
                                  themeData.textTheme.subtitle2,
                                  letterSpacing: 0.1,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 500),
                              hintText: Translator.translate("password"),
                              border: allTFBorder,
                              enabledBorder: allTFBorder,
                              focusedBorder: allTFBorder,
                              prefixIcon: Icon(
                                MdiIcons.lockOutline,
                                size: 22,
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                child: Icon(
                                  showPassword
                                      ? MdiIcons.eyeOutline
                                      : MdiIcons.eyeOffOutline,
                                  size: MySize.size22,
                                ),
                              ),
                              isDense: true,
                              contentPadding: Spacing.zero,
                            ),
                            controller: passwordTFController,
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: FlutButton.medium(
                            backgroundColor: appdata == null  ? Colors.purple : HexColor(appdata!.first.mainColor),
                            borderRadiusAll: 8,
                            onPressed: () {
                              if (!isInProgress) {
                                _handleRegister();
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    Translator.translate("create").toUpperCase(),
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.bodyText2,
                                        color: themeData
                                            .colorScheme.onPrimary,
                                        letterSpacing: 0.8,
                                        fontWeight: 700),
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  child: isInProgress

                                      ? Container(
                                    width: MySize.size16,
                                    height: MySize.size16,
                                    child: CircularProgressIndicator(
                                        valueColor:
                                        AlwaysStoppedAnimation<
                                            Color>(
                                            themeData
                                                .colorScheme
                                                .onPrimary),
                                        strokeWidth: 1.4),
                                  )
                                      : ClipOval(
                                    child: Container(
                                      color: appdata == null  ? Colors.purple : HexColor(appdata!.first.mainColor),

                                      child: SizedBox(
                                          width: MySize.size30,
                                          height: MySize.size30,
                                          child: Icon(
                                            MdiIcons.arrowRight,
                                            color: themeData
                                                .colorScheme
                                                .onPrimary,
                                            size: MySize.size18,
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            margin: Spacing.top(16),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              },
                              child: Text(
                                Translator.translate("i_have_already_an_account"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ),
                        AuthController.notice(themeData)
                      ],
                    ))));
      },
    );
  }
}
