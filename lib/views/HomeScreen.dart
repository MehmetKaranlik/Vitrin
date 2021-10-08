import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';
import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import '../api/api_util.dart';
import '../controllers/AddressController.dart';
import '../controllers/AppDataController.dart';
import '../controllers/HomeController.dart';
import '../models/AdBanner.dart';
import '../models/AppData.dart';
import '../models/Category.dart';
import '../models/MyResponse.dart';
import '../models/Shop.dart';
import '../models/Stories.dart';
import '../models/UserAddress.dart';
import '../services/AppLocalizations.dart';
import '../utils/SizeConfig.dart';
import '../utils/TextUtils.dart';
import 'ShopScreen.dart';
import 'addresses/AddAddressScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'StoryScreen.dart';
import 'addresses/HomeFilterScreen.dart';
import 'package:sizer/sizer.dart';
import '../widgets/sized_place_holder.dart';

class HomeScreen extends StatefulWidget {
  final double? myDistance;
  const HomeScreen({Key? key, this.myDistance}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? myDistance;
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

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
  // Timer? timerAnimation;
  bool isInProgress = false;
  List<Shop>? shops;
  List<UserAddress>? userAddresses;
  List<Category>? categories;
  List<Stories>? stories;
  List<AdBanner>? banners;
  List<AppData>? appdata;
  late double? enlem;
  late double? boylam;
  int selectedAddress = -1;
  Position? position;
  double? farkkm;
  double? currentLat;
  double? currentLong;
  double? apiLat;
  double? apiLong;
  double? distanceApi;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    getAppData();
    _getLocation();
  }

  @override
  void dispose() {
    super.dispose();
    /*if (timerAnimation != null) timerAnimation!.cancel();
    if (_pageController != null) _pageController!.dispose();*/
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
      _loadHomeData();
    }
  }

  _getLocation() async {
    position = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  Widget _calculateKm(lat1, long1, lat2, long2) {
    if (Geolocator.distanceBetween(lat1, long1, lat2, long2) < 1000) {
      double tali = Geolocator.distanceBetween(lat1, long1, lat2, long2);
      return Text("${tali.toStringAsFixed(1)} M",
          style: AppTheme.getTextStyle(themeData.textTheme.subtitle1,
              fontWeight: 600));
    } else {
      double mali = Geolocator.distanceBetween(lat1, long1, lat2, long2) / 1000;
      return Text("${mali.toStringAsFixed(1)} KM",
          style: AppTheme.getTextStyle(themeData.textTheme.subtitle1,
              fontWeight: 600));
    }
  }

  /*_calculateFilter(currentLat, currentLong, apiLat, apiLong) async {
    double distanceApi = Geolocator.distanceBetween(currentLat, currentLong, apiLat, apiLong);
    setState(() {});
  }*/

  _loadHomeData() async {
    if (selectedAddress == -1) return;
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }
    MyResponse<Map<String, dynamic>> myResponse =
        await HomeController.getHomeData(userAddresses![selectedAddress].id);
    if (myResponse.success) {
      stories = myResponse.data![HomeController.stories];
      shops = myResponse.data![HomeController.shops];
      banners = myResponse.data![HomeController.banners];
      categories = myResponse.data![HomeController.categories];
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
    _loadHomeData();
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
              child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: customAppTheme.bgLayer1,
                  body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme.bgLayer1,
                    color: themeData.colorScheme.primary,
                    key: _refreshIndicatorKey,
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
                        Expanded(
                          child: _buildBody(),
                        )
                      ],
                    ),
                  )),
            ));
      },
    );
  }

  _buildBody() {
    if (!isInProgress &&
        (userAddresses == null || userAddresses?.length == 0)) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddAddressScreen()));
          },
          child: Text("Create an Address"),
        ),
      );
    }

    if (shops != null &&
        categories != null &&
        banners != null &&
        stories != null) {
      final List<Widget> imageSliders =
          banners!.map((item) => _buildAdBanner(item)).toList();
      return Stack(children: [
        ListView(
          children: [
            _buildAdBannerSlider(imageSliders),

            /*_addressWidget(),*/
            //  _filterWidget(),
            SizedPlaceHolder(color: Colors.transparent, height: 0.h, width: 0),
            Divider(
              thickness: 1,
            ),
            _storiesWidget(stories!),
            Divider(
              thickness: 1,
            ),
            _shopsWidget(shops!),
          ],
        ),
      ]);
    } else if (isInProgress) {
      return Container();
    } else {
      return Container();
    }
  }

  CarouselSlider _buildAdBannerSlider(List<Widget> imageSliders) {
    return CarouselSlider(
      items: imageSliders,
      options: CarouselOptions(
        viewportFraction: .95,
        pauseAutoPlayOnTouch: true,
        autoPlayInterval: Duration(seconds: 10),
        autoPlayAnimationDuration: Duration(seconds: 3),
        enlargeCenterPage: true,
        aspectRatio: 5.5,
        autoPlay: true,
      ),
    );
  }

  Container _buildAdBanner(AdBanner item) {
    return Container(
      margin: EdgeInsets.fromLTRB(1.w, 2.w, 1.w, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Image.network(
          TextUtils.getImageUrl(item.url),
          fit: BoxFit.fill,
        ),
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

  _shopsWidget(List<Shop> shops) {
    List<Widget> listWidgets = [];
    for (Shop shop in shops) {
      double shopmesafe = Geolocator.distanceBetween(
          position == null ? 0.0 : position!.latitude,
          position == null ? 0.0 : position!.longitude,
          shop.latitude,
          shop.longitude);
      if (myDistance == null) {
        listWidgets.add(InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShopScreen(
                          shopId: shop.id,
                        )));
          },
          child: Container(
            margin: Spacing.bottom(24),
            child: _singleShop(shop),
          ),
        ));
      } else {
        if (shopmesafe < myDistance!) {
          listWidgets.add(InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShopScreen(
                            shopId: shop.id,
                          )));
            },
            child: Container(
              margin: Spacing.bottom(24),
              child: _singleShop(shop),
            ),
          ));
        }
      }
    }

    return Container(
      margin: Spacing.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: listWidgets,
      ),
    );
  }

  _singleShop(Shop shop) {
    return Container(
      decoration: BoxDecoration(
        color: customAppTheme.bgLayer2,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: themeData.cardTheme.shadowColor!.withAlpha(32),
            blurRadius: 6,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(MySize.size16!),
                  topRight: Radius.circular(MySize.size16!)),
              child: Image.network(
                shop.imageUrl,
                width: MySize.safeWidth,
                fit: BoxFit.cover,
              )),
          Container(
            padding: Spacing.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Text(shop.name,
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.subtitle1,
                              fontWeight: 600)),
                    ),
                    new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _calculateKm(
                              position == null ? 0.0 : position!.latitude,
                              position == null ? 0.0 : position!.longitude,
                              shop.latitude,
                              shop.longitude),
                        ]),
                  ],
                ),
                Container(
                  margin: Spacing.top(8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  MdiIcons.mapMarkerOutline,
                                  color: appdata == null
                                      ? Colors.purple
                                      : HexColor(appdata!.first.mainColor),
                                  size: MySize.size14,
                                ),
                                Expanded(
                                  child: Container(
                                      margin: Spacing.left(8),
                                      child: Text(
                                        shop.address,
                                        style: AppTheme.getTextStyle(
                                            themeData.textTheme.caption,
                                            fontWeight: 500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                ),
                              ],
                            ),
                            Container(
                              margin: Spacing.top(4),
                              child: Row(
                                children: <Widget>[
                                  Icon(MdiIcons.phoneOutline,
                                      color: appdata == null
                                          ? Colors.purple
                                          : HexColor(appdata!.first.mainColor),
                                      size: 14),
                                  Container(
                                    margin: Spacing.left(8),
                                    child: Text(
                                      shop.mobile,
                                      style: AppTheme.getTextStyle(
                                          themeData.textTheme.caption,
                                          color: themeData
                                              .colorScheme.onBackground),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      _buildEnterShopButton(shop),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  ElevatedButton _buildEnterShopButton(Shop shop) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(shop.isOpen
            ? appdata == null
                ? Colors.purple
                : Colors.white
            : Colors.white),
        shadowColor: MaterialStateProperty.all(shop.isOpen
            ? appdata == null
                ? Colors.purple
                : HexColor(appdata!.first.secondColor)
            : customAppTheme.colorError.withAlpha(28)),
        padding: MaterialStateProperty.all(Spacing.xy(10, 10)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShopScreen(
                      shopId: shop.id,
                    )));
      },
      child: Text(
        "Mağazaya Gir",
        style: AppTheme.getTextStyle(themeData.textTheme.caption,
            fontWeight: 600, color: Colors.green),
      ),
    );
  }

  List<Widget> storyList = [];

  _storiesWidget(List<Stories> stories) {
    for (Stories story in stories) {
      if (storyList.length < stories.length) {
        storyList.add(
          InkWell(
            onTap: () async {
              await showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  isScrollControlled: true,
                  context: context,
                  builder: (_) {
                    return StoryScreen(shopId: story.shopId);
                  });
            },
            child: _singleStory(story),
          ),
        );
      }
    }

    return Container(
      height: 8.h,
      width: 100.w,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        scrollDirection: Axis.horizontal,
        children: storyList,
        shrinkWrap: true,
      ),
    );
  }

  _singleStory(Stories stories) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.5.w),
      height: 8.h,
      width: 8.h,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              spreadRadius: 0.3.w,
              color: Colors.black87.withOpacity(0.2),
            ),
          ],
          image: DecorationImage(
              fit: BoxFit.fitHeight,
              image: NetworkImage(
                stories.storyImage,
              )),
          border: Border.all(width: 0.5.w, color: Colors.blue[700]!),
          color: themeData.colorScheme.primary.withAlpha(20).withOpacity(0.3),
          shape: BoxShape.circle),

      //color: themeData.colorScheme.primary.withAlpha(20),
    );
  }

  _addressWidget() {
    return GestureDetector(
      onTap: () {
        dynamic state = _addressSelectionKey.currentState;
        state.showButtonMenu();
      },
      child: Container(
        padding: Spacing.x(8),
        margin: Spacing.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: customAppTheme.bgLayer4, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: Spacing.left(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          userAddresses![selectedAddress].address,
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText2,
                              color: themeData.colorScheme.onBackground,
                              fontWeight: 600),
                        ),
                        Text(
                          userAddresses![selectedAddress].city +
                              " - " +
                              userAddresses![selectedAddress]
                                  .pincode
                                  .toString(),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.caption,
                              fontSize: 11,
                              color: themeData.colorScheme.onBackground
                                  .withAlpha(150),
                              fontWeight: 500),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton(
                  key: _addressSelectionKey,
                  icon: Icon(
                    MdiIcons.chevronDown,
                    color: themeData.colorScheme.onBackground,
                    size: 20,
                  ),
                  onSelected: (dynamic value) async {
                    if (value == -1) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddAddressScreen()));
                      _refresh();
                    } else {
                      setState(() {
                        selectedAddress = value;
                      });
                      _refresh();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    var list = <PopupMenuEntry<Object>>[];
                    for (int i = 0; i < userAddresses!.length; i++) {
                      list.add(PopupMenuItem(
                        value: i,
                        child: Container(
                          margin: Spacing.vertical(2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userAddresses![i].address,
                                  style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    fontWeight: 600,
                                    color: themeData.colorScheme.onBackground,
                                  )),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                    userAddresses![i].city +
                                        " - " +
                                        userAddresses![i].pincode.toString(),
                                    style: AppTheme.getTextStyle(
                                      themeData.textTheme.caption,
                                      color: themeData.colorScheme.onBackground,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ));
                      list.add(
                        PopupMenuDivider(
                          height: 10,
                        ),
                      );
                    }
                    list.add(PopupMenuItem(
                      value: -1,
                      child: Container(
                        margin: Spacing.vertical(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              MdiIcons.plus,
                              color: themeData.colorScheme.onBackground,
                              size: 20,
                            ),
                            Container(
                              margin: Spacing.left(4),
                              child: Text(
                                  Translator.translate("add_new_address"),
                                  style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    color: themeData.colorScheme.onBackground,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ));
                    return list;
                  },
                  color: themeData.backgroundColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _filterWidget() {
    return Container(
      margin: Spacing.fromLTRB(16, 20, 16, 0),
      child: Column(children: [
        ElevatedButton.icon(
          icon: Icon(
            Icons.location_on_outlined,
            color: appdata == null
                ? Colors.purple
                : HexColor(appdata!.first.mainColor),
            size: 24.0,
          ),
          style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 40),
              primary: Colors.white,
              onPrimary: appdata == null
                  ? Colors.purple
                  : HexColor(appdata!.first.mainColor),
              side: BorderSide(
                width: 2.0,
                color: appdata == null
                    ? Colors.purple
                    : HexColor(appdata!.first.mainColor),
              )),
          onPressed: () async {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeFilterScreen()))
                .then((value) {
              setState(() {
                myDistance = value;
              });
              _shopsWidget(shops!);
            });
          },
          label: Text("Lokasyon Seç"),
        ),
      ]),
    );
  }

  /*_bannersWidget() {
    if (banners!.length == 0) return Container();
    if (_pageController == null) {
      _pageController = PageController(initialPage: 0);
      _numPages = banners!.length;
      timerAnimation = Timer.periodic(Duration(seconds: 5), (Timer timer) {
        if (_currentPage < _numPages - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController!.hasClients) {
          _pageController!.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        }
      });
    }

    List<Widget> list = [];
    for (AdBanner banner in banners!) {
      list.add(
        Padding(
          padding: Spacing.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Image.network(
              TextUtils.getImageUrl(banner.url),
              fit: BoxFit.cover,
              height: 240,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 266,
      child: PageView(
        pageSnapping: true,
        physics: ClampingScrollPhysics(),
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: list,
      ),
    );
  }*/
}
