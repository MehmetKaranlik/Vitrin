import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sizer/sizer.dart';
import 'package:vitrinint/AppTheme.dart';
import 'package:vitrinint/AppThemeNotifier.dart';
import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/controllers/AddressController.dart';
import 'package:vitrinint/controllers/HomeController.dart';
import 'package:vitrinint/controllers/StoryController.dart';
import 'package:vitrinint/models/AdBanner.dart';
import 'package:vitrinint/models/Category.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/models/Shop.dart';
import 'package:vitrinint/models/Stories.dart';
import 'package:vitrinint/models/UserAddress.dart';
import 'package:vitrinint/services/AppLocalizations.dart';
import 'package:vitrinint/utils/ColorUtils.dart';
import 'package:vitrinint/utils/Generator.dart';
import 'package:vitrinint/utils/SizeConfig.dart';
import 'package:vitrinint/utils/TextUtils.dart';
import 'package:vitrinint/views/CategoryProductScreen.dart';
import 'package:vitrinint/views/ShopScreen.dart';
import 'package:vitrinint/views/addresses/AddAddressScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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

  _loadStoryData() async {
    if (selectedAddress == -1) return;
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Map<String, dynamic>> myResponse =
        await StoryController.getStoryData(widget.shopId);
    if (myResponse.success) {
      stories = myResponse.data![StoryController.stories];
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
          home: Scaffold(
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
        );
      },
    );
  }

  _buildBody() {
    if (stories != null) {
      int storyCount = stories!.length;
      int spaceCount = storyCount - 1;
      double width = (98 - 0.4 * spaceCount) / storyCount;
      return Center(
        child: Stack(
          children: [
            _storiesWidget(stories!),
            Positioned(
              top: 7.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: Container(
                    height: 0.5.h,
                    width: 100.w,
                    child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => SizedBox(
                        width: 0.4.w,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: stories!.length,
                      itemBuilder: (context, index) {
                        return Ink(
                          height: 1.h,
                          width: width.w,
                          decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0.1.w))),
                        );
                      },
                    )),
              ),
            ),
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

  Positioned _buildGoToShopButton() {
    return Positioned(
      top: 1.h,
      left: 3.w,
      child: Container(
        alignment: Alignment.center,
        height: 5.7.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              transform: GradientRotation(4),
              colors: [Colors.white, Colors.white]),
          borderRadius: BorderRadius.all(Radius.circular(2.w)),
          shape: BoxShape.rectangle,
          color: Colors.white,
        ),
        child: TextButton(
          onPressed: () => Get.off(() => ShopScreen(
                shopId: stories![0].shopId,
              )),
          child: Text(
            "Mağazaya Git",
            style: TextStyle(
                fontSize: 11.sp,
                color: Colors.blue[700],
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }

  Positioned _buildExitButton() {
    return Positioned(
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

  _storiesWidget(List<Stories> stories) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(width: 0.2.w, color: Colors.white)),
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: PhotoViewGallery.builder(
        gaplessPlayback: true,
        enableRotation: true,
        customSize: Size.fromHeight(80.h),
        itemCount: stories.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(
              stories[index].storyImage,
            ),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 30.0,
            height: 30.0,
            child: CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
              value: event == null ? 0 : event.cumulativeBytesLoaded / 3,
            ),
          ),
        ),
      ),
    );
  }
}
