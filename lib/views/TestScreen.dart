import 'dart:developer';

import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<TestScreen> {
  //Theme Data
  ThemeData? themeData;
  late CustomAppTheme customAppTheme;

  @override
  void initState() {
    super.initState();
  }

  setError(e) {
    log(e.toString());
  }

  test() async {}

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: SafeArea(
              child: Scaffold(
                  backgroundColor: customAppTheme.bgLayer1,
                  resizeToAvoidBottomInset: false,
                  body: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            test();
                          },
                          child: Text("Click"))
                    ],
                  )),
            ));
      },
    );
  }
}
