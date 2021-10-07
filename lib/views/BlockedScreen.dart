import 'package:vitrinint/controllers/AppDataController.dart';
import 'package:vitrinint/controllers/AuthController.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/services/AppLocalizations.dart';
import 'package:vitrinint/utils/SizeConfig.dart';
import 'package:vitrinint/utils/UrlUtils.dart';
import 'package:vitrinint/views/AppScreen.dart';
import 'package:vitrinint/views/auth/LoginScreen.dart';
import 'package:vitrinint/widgets/FlutButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import 'auth/OTPVerificationScreen.dart';

//----------------------------- Maintenance Screen -------------------------------//

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({Key? key}) : super(key: key);

  @override
  _BlockedScreenState createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  //ThemeData
  late ThemeData themeData;
  bool isInProgress = false;

  @override
  void initState() {
    super.initState();
  }

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  _checkBlockStatus() async {
    setState(() {
      isInProgress = true;
    });

    MyResponse myResponse = await AppDataController.getAppData();

    if (myResponse.success) {
      if (myResponse.data!.user != null) {
        await AuthController.saveUserFromUser(myResponse.data!.user!);
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => OTPVerificationScreen(),
          ),
          (route) => false,
        );
      } else if (authType == AuthType.BLOCKED) {
        showMessage(message: "You are still blocked");
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginScreen(),
          ),
        );
      }
    } else {
      showMessage(message: "Please wait for some time");
    }

    setState(() {
      isInProgress = false;
    });
  }

  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        return MaterialApp(
            scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                key: _scaffoldKey,
                backgroundColor: themeData.backgroundColor,
                body: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 3,
                        child: isInProgress
                            ? LinearProgressIndicator(
                                minHeight: 3,
                              )
                            : Container(
                                height: 3,
                              ),
                      ),
                      Container(
                        child: Image(
                          image: AssetImage('./assets/images/maintenance.png'),
                        ),
                      ),
                      Container(
                        margin: Spacing.top(24),
                        child: Text(
                          Translator.translate("your_account_was_suspended"),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText1,
                              color: themeData.colorScheme.onBackground,
                              fontWeight: 600,
                              letterSpacing: 0.2),
                        ),
                      ),
                      Container(
                        margin: Spacing.fromLTRB(24, 24, 24, 0),
                        child: Text(
                          "Please contact admin or refresh",
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText1,
                              color: themeData.colorScheme.onBackground,
                              fontWeight: 500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Spacing.height(16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            UrlUtils.sendMailToAdmin();
                          },
                          child: Text(Translator.translate("contact_admin")),
                        ),
                      ),
                      Container(
                          margin: Spacing.only(left: 56, right: 56, top: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FlutButton.rounded(
                                onPressed: () {
                                  _checkBlockStatus();
                                },
                                child: Text(
                                  Translator.translate("refresh"),
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText1,
                                      color: themeData.colorScheme.onPrimary),
                                ),
                              ),
                              FlutButton.rounded(
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
                                child: Text(
                                  Translator.translate("logout"),
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText1,
                                      color: themeData.colorScheme.onPrimary),
                                ),
                              ),
                            ],
                          ))
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
}
