import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sizer/sizer.dart';
import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import '../api/api_util.dart';
import '../controllers/AppDataController.dart';
import '../models/AppData.dart';
import '../models/MyResponse.dart';
import '../utils/SizeConfig.dart';
import 'CartScreen.dart';
import 'FavoriteScreen.dart';
import 'HomeScreen.dart';
import 'SearchScreen.dart';
import 'auth/SettingScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'addresses/HomeFilterScreen.dart';

class AppScreen extends StatefulWidget {
  final int selectedPage;

  const AppScreen({Key? key, this.selectedPage = 0}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  List<AppData>? appdata;
  TabController? _tabController;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController!.index;
    });
  }

  @override
  void initState() {
    _tabController = new TabController(
      length: 4,
      vsync: this,
      initialIndex: 0,
    );
    _tabController!.addListener(_handleTabSelection);
    getAppData();
    super.initState();
  }

  dispose() {
    super.dispose();
    _tabController!.dispose();
  }

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

  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeMode = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeMode);
        customAppTheme = AppTheme.getCustomAppTheme(themeMode);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
          home: Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: _buildFloatingActionButton(),
            backgroundColor: customAppTheme.bgLayer1,
            bottomNavigationBar: _buildAnimatedButtomNavigationBar(context),
            body: TabBarView(
              controller: _tabController,
              children: _buildBottomBarItems(),
            ),
          ),
        );
      },
    );
  }

  _buildFloatingActionButton() {
    return Material(
      child: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomeFilterScreen())),
        child: Icon(
          Icons.location_on_outlined,
          size: 6.5.w,
        ),
      ),
    );
  }

  List<IconData> listBottomNavigationBarIcons = [
    MdiIcons.store,
    MdiIcons.magnify,
    MdiIcons.heart,
    MdiIcons.account,
  ];
/*  SafeArea _buildButtomNavigationBar() {
    return SafeArea(
      child: BottomAppBar(
          elevation: 0,
          shape: CircularNotchedRectangle(),
          child: Container(
            decoration: BoxDecoration(
              color: customAppTheme.bgLayer1,
              boxShadow: [
                BoxShadow(
                  color: themeData.cardTheme.shadowColor!.withAlpha(40),
                  blurRadius: 3,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            padding: Spacing.only(top: 12, bottom: 12),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: appdata == null ? Colors.purple : Colors.purple,
              tabs: <Widget>[
                Container(
                  child: (_currentIndex == 0)
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              MdiIcons.store,
                              color: appdata == null
                                  ? Colors.purple
                                  : HexColor(appdata!.first.mainColor),
                            ),
                            Container(
                              margin: Spacing.top(4),
                              decoration: BoxDecoration(
                                  color: appdata == null
                                      ? Colors.purple
                                      : HexColor(appdata!.first.mainColor),
                                  borderRadius: new BorderRadius.all(
                                      Radius.circular(2.5))),
                              height: 5,
                              width: 5,
                            )
                          ],
                        )
                      : Icon(
                          MdiIcons.storeOutline,
                          color: appdata == null
                              ? Colors.purple
                              : HexColor(appdata!.first.mainColor),
                        ),
                ),
                Container(
                    child: (_currentIndex == 1)
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                MdiIcons.magnify,
                                color: appdata == null
                                    ? Colors.purple
                                    : HexColor(appdata!.first.mainColor),
                              ),
                              Container(
                                margin: Spacing.top(4),
                                decoration: BoxDecoration(
                                    color: appdata == null
                                        ? Colors.purple
                                        : HexColor(appdata!.first.mainColor),
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(2.5))),
                                height: 5,
                                width: 5,
                              )
                            ],
                          )
                        : Icon(
                            MdiIcons.magnify,
                            color: appdata == null
                                ? Colors.purple
                                : HexColor(appdata!.first.mainColor),
                          )),
                Container(
                    child: (_currentIndex == 2)
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                MdiIcons.heart,
                                color: appdata == null
                                    ? Colors.purple
                                    : HexColor(appdata!.first.mainColor),
                              ),
                              Container(
                                margin: Spacing.top(4),
                                decoration: BoxDecoration(
                                    color: appdata == null
                                        ? Colors.purple
                                        : HexColor(appdata!.first.mainColor),
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(2.5))),
                                height: 5,
                                width: 5,
                              )
                            ],
                          )
                        : Icon(
                            MdiIcons.heartOutline,
                            color: appdata == null
                                ? Colors.purple
                                : HexColor(appdata!.first.mainColor),
                          )),
                Container(
                    child: (_currentIndex == 3)
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                MdiIcons.account,
                                color: appdata == null
                                    ? Colors.purple
                                    : HexColor(appdata!.first.mainColor),
                              ),
                              Container(
                                margin: Spacing.top(4),
                                decoration: BoxDecoration(
                                    color: appdata == null
                                        ? Colors.purple
                                        : HexColor(appdata!.first.mainColor),
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(2.5))),
                                height: 5,
                                width: 5,
                              )
                            ],
                          )
                        : Icon(
                            MdiIcons.accountOutline,
                            color: appdata == null
                                ? Colors.purple
                                : HexColor(appdata!.first.mainColor),
                          )),
              ],
            ),
          )),
    );
  }*/

  List<Widget> _buildBottomBarItems() {
    return <Widget>[
      HomeScreen(),
      SearchScreen(),
      FavoriteScreen(),
      SettingScreen()
    ];
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
                letterSpacing: 0.4, color: Colors.purple)),
        backgroundColor: themeData.colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  _buildAnimatedButtomNavigationBar(BuildContext context) {
    List<Widget> navigationBarIcons = [];
    return AnimatedBottomNavigationBar.builder(
        itemCount: _tabController!.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Colors.black : Colors.black.withOpacity(0.4);
          return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  listBottomNavigationBarIcons[index],
                  size: 24,
                  color: color,
                )
              ]);
        },
        backgroundColor: themeData.bottomNavigationBarTheme.backgroundColor,
        elevation: 70,
        activeIndex: _tabController!.index,
        splashColor: Colors.transparent,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        onTap: (index) => _tabController!.index = index);
  }
}
