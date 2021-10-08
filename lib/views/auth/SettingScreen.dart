import 'package:hexcolor/hexcolor.dart';
import '../../api/api_util.dart';
import '../../controllers/AppDataController.dart';
import '../../controllers/AuthController.dart';
import '../../models/Account.dart';
import '../../models/AppData.dart';
import '../../models/MyResponse.dart';
import '../../services/AppLocalizations.dart';
import '../../utils/ImageUtils.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/UrlUtils.dart';
import '../addresses/AllAddressScreen.dart';
import 'EditProfileScreen.dart';
import 'LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../SelectLanguageDialog.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  ThemeData? themeData;
  late CustomAppTheme customAppTheme;

  //User
  Account? account;
  List<AppData>? appdata;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    Account cacheAccount = await AuthController.getAccount();
    setState(() {
      account = cacheAccount;
    });
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  getAppData() async {
    MyResponse<Map<String, dynamic>> myResponse =
        await AppDataController.getAppData();
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
            style: AppTheme.getTextStyle(themeData!.textTheme.subtitle2,
                letterSpacing: 0.4, color: themeData!.colorScheme.onPrimary)),
        backgroundColor: themeData!.colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeData,
            home: Scaffold(
                backgroundColor: customAppTheme.bgLayer1,
                appBar: AppBar(
                  backgroundColor: customAppTheme.bgLayer1,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(Translator.translate("setting"),
                      style: AppTheme.getTextStyle(
                          themeData!.appBarTheme.textTheme!.headline6,
                          fontWeight: 600)),
                ),
                body: buildBody()));
      },
    );
  }

  buildBody() {
    if (account != null) {
      return ListView(
        children: <Widget>[
          Container(
            margin: Spacing.fromLTRB(24, 0, 24, 0),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => EditProfileScreen(),
                  ),
                );
                _initData();
              },
              child: Row(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.all(
                          Radius.circular(MySize.getScaledSizeWidth(24))),
                      child: ImageUtils.getImageFromNetwork(
                          account!.getAvatarUrl(),
                          width: 48,
                          height: 48)),
                  Container(
                    margin: Spacing.left(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(account!.name!,
                            style: AppTheme.getTextStyle(
                                themeData!.textTheme.subtitle1,
                                fontWeight: 700,
                                letterSpacing: 0)),
                        Text(account!.email!,
                            style: AppTheme.getTextStyle(
                                themeData!.textTheme.caption,
                                fontWeight: 600,
                                letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        child: Icon(
                          MdiIcons.chevronRight,
                          color: themeData!.colorScheme.onBackground,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 8, 16, 0),
            child: ListTile(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => SelectLanguageDialog());
              },
              title: Text(
                Translator.translate("select_language"),
                style: AppTheme.getTextStyle(themeData!.textTheme.subtitle2,
                    fontWeight: 600),
              ),
              trailing: Icon(Icons.chevron_right,
                  color: themeData!.colorScheme.onBackground),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 0, 16, 0),
            child: ListTile(
              onTap: () {
                UrlUtils.openFeedbackUrl();
              },
              title: Text(
                Translator.translate("Feedback"),
                style: AppTheme.getTextStyle(themeData!.textTheme.subtitle2,
                    fontWeight: 600),
              ),
              trailing: Icon(Icons.chevron_right,
                  color: themeData!.colorScheme.onBackground),
            ),
          ),
          Container(
            margin: Spacing.top(16),
            child: Center(
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(appdata == null
                        ? Colors.purple
                        : HexColor(appdata!.first.mainColor)),
                    padding: MaterialStateProperty.all(Spacing.xy(24, 12)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ))),
                onPressed: () async {
                  await AuthController.logoutUser();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => LoginScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(MdiIcons.logoutVariant,
                        size: MySize.size20,
                        color: themeData!.colorScheme.onPrimary),
                    Container(
                      margin: Spacing.left(16),
                      child: Text(Translator.translate("logout").toUpperCase(),
                          style: AppTheme.getTextStyle(
                              themeData!.textTheme.caption,
                              fontWeight: 600,
                              color: themeData!.colorScheme.onPrimary,
                              letterSpacing: 0.3)),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return Container();
    }
  }
}
