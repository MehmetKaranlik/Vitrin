import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'controllers/AppDataController.dart';
import 'controllers/AuthController.dart';
import 'models/AppData.dart';
import 'models/MyResponse.dart';
import 'services/AppLocalizations.dart';
import 'services/PushNotificationsManager.dart';
import 'utils/SizeConfig.dart';
import 'views/AppScreen.dart';
import 'views/BlockedScreen.dart';
import 'views/MaintenanceScreen.dart';
import 'views/SearchScreen.dart';
import 'views/auth/LoginScreen.dart';
import 'views/auth/OTPVerificationScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'AppTheme.dart';
import 'AppThemeNotifier.dart';
import 'api/api_util.dart';

Future<void> main() async {
  //You will need to initialize AppThemeNotifier class for theme changes.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) async {
    String langCode = await AllLanguage.getLanguage();
    await Translator.load(langCode);
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<AppThemeNotifier>(
            create: (context) => AppThemeNotifier()),
      ],
      child: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        return Sizer(
          builder: (context, orientation, deviceType) {
            return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
                home: MyHomePage());
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ThemeData? themeData;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();
  @override
  void initState() {
    super.initState();
    initFCM();
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

  initFCM() async {
    PushNotificationsManager pushNotificationsManager =
        PushNotificationsManager();
    await pushNotificationsManager.init();
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    themeData = Theme.of(context);
    return FutureBuilder<AuthType>(
        future: AuthController.userAuthType(),
        builder: (context, AsyncSnapshot<AuthType> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == AuthType.VERIFIED) {
              return AppScreen();
            } else if (snapshot.data == AuthType.LOGIN) {
              return OTPVerificationScreen();
            } else if (snapshot.data == AuthType.BLOCKED) {
              return BlockedScreen();
            } else {
              return LoginScreen();
            }
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
