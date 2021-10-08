import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';
import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import '../api/api_util.dart';
import '../controllers/AddressController.dart';
import '../controllers/StoryController.dart';
import '../controllers/carousel_controller.dart';
import '../controllers/story_index_controller.dart';

import '../models/AdBanner.dart';
import '../models/Category.dart';
import '../models/MyResponse.dart';
import '../models/Shop.dart';
import '../models/Stories.dart';
import '../models/UserAddress.dart';
import '../utils/SizeConfig.dart';
import 'ShopScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoryScreen extends StatefulWidget {
  final int? shopId;

  const StoryScreen({Key? key, this.shopId}) : super(key: key);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  //ThemeData

  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey _addressSelectionKey = new GlobalKey();

  //Banner Variables
  int _numPages = 3;

  PageController? _pageController;
  int _currentPage = 0;
  Timer? timerAnimation;

  //Other Variables
  bool isInProgress = false;
  List<Shop>? shops;
  List<UserAddress>? userAddresses;
  List<Category>? categories;
  List<Stories>? stories;
  List<StoryItem> storyItems = [];
  List<AdBanner>? banners;

  int selectedAddress = -1;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    super.dispose();
    if (timerAnimation != null) timerAnimation!.cancel();
    if (_pageController != null) _pageController!.dispose();
  }

  _loadAddresses() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<UserAddress>> userAddressResponse =
        await AddressController.getMyAddresses();
    if (userAddressResponse.success) {
      userAddresses = userAddressResponse.data;
    } else {
      ApiUtil.checkRedirectNavigation(
          context, userAddressResponse.responseCode);
      showMessage(message: userAddressResponse.errorText);
    }

    if (userAddresses == null || userAddresses?.length == 0) {
      if (mounted) {
        setState(() {
          isInProgress = false;
        });
      }
    } else {
      if (selectedAddress == -1) {
        selectedAddress = 0;
        for (int i = 0; i < userAddresses!.length; i++) {
          if (userAddresses![i].isDefault) selectedAddress = i;
        }
      }
      _loadStoryData();
    }
  }

  void loadStoryImages(so, List<StoryItem> targetList) {
    for (var i = 0; i < stories!.length; i++) {
      storyItems.add(StoryItem.pageImage(
          duration: Duration(seconds: 10),
          url: stories![i].storyImage,
          controller: _storyController));
    }
  }

  _loadStoryData() async {
    if (selectedAddress == -1) return;
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Map<String, dynamic>> myResponse =
        await OldStoryController.getStoryData(widget.shopId);
    if (myResponse.success) {
      stories = myResponse.data![OldStoryController.stories];
      loadStoryImages(stories, storyItems);
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  Future<void> _refresh() async {
    _loadStoryData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
          scaffoldMessengerKey: _scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
          home: SafeArea(
            top: true,
            child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: Colors.black.withOpacity(0.9),
                body: RefreshIndicator(
                  onRefresh: _refresh,
                  backgroundColor: customAppTheme.bgLayer1,
                  color: themeData.colorScheme.primary,
                  key: _refreshIndicatorKey,
                  child: Column(
                    children: [
                      Container(
                        child: isInProgress
                            ? LinearProgressIndicator(
                                minHeight: MySize.size3,
                              )
                            : Container(),
                      ),
                      Expanded(
                        child: _buildBody(),
                      )
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }

  _buildBody() {
    if (stories != null) {
      return Center(
        child: Stack(
          children: [
            _storiesWidget(stories!),
            _buildExitButton(),
            _buildGoToShopButton()
          ],
        ),
      );
    } else if (isInProgress) {
      return Container();
    } else {
      return Container();
    }
  }

  IndexController _indexController = IndexController();

  Positioned _buildGoToShopButton() {
    return Positioned(
        top: 5.h,
        left: 3.w,
        child: Container(
          child: Image.network(stories![0].shopImage),
        ));
  }

  Positioned _buildExitButton() {
    return Positioned(
      top: 5.w,
      right: 3.w,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.close_rounded),
      ),
    );
  }

  showMessage({String message = "Something wrong", Duration? duration}) {
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

  StoryController _storyController = StoryController();
  _storiesWidget(List<Stories> stories) {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        border: Border.all(width: 0.2.w, color: Colors.white),
      ),
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: StoryView(controller: _storyController, storyItems: storyItems),
    );
  }
}
