import 'dart:async';
import 'dart:developer';

import 'package:hexcolor/hexcolor.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitrinint/AppTheme.dart';
import 'package:vitrinint/AppThemeNotifier.dart';
import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/api/currency_api.dart';
import 'package:vitrinint/controllers/AppDataController.dart';
import 'package:vitrinint/controllers/CartController.dart';
import 'package:vitrinint/controllers/FavoriteController.dart';
import 'package:vitrinint/controllers/ProductController.dart';
import 'package:vitrinint/controllers/ShopController.dart';
import 'package:vitrinint/models/AppData.dart';
import 'package:vitrinint/models/MyResponse.dart';
import 'package:vitrinint/models/Product.dart';
import 'package:vitrinint/models/ProductImage.dart';
import 'package:vitrinint/models/Shop.dart';
import 'package:vitrinint/services/AppLocalizations.dart';
import 'package:vitrinint/utils/Generator.dart';
import 'package:vitrinint/utils/ProductUtils.dart';
import 'package:vitrinint/utils/SizeConfig.dart';
import 'package:vitrinint/utils/TextUtils.dart';
import 'package:vitrinint/utils/UrlUtils.dart';
import 'package:vitrinint/views/CartScreen.dart';
import 'package:vitrinint/views/LoadingScreens.dart';
import 'package:vitrinint/views/ShopScreen.dart';
import 'package:vitrinint/views/ImagesScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'StoryScreen.dart';

class ProductScreen extends StatefulWidget {
  final int productId;

  const ProductScreen({Key? key, required this.productId}) : super(key: key);
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  //Theme Data
  ThemeData? themeData;
  CustomAppTheme? customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();
  final GlobalKey _productItemSelectKey = new GlobalKey();

  //Other Variables
  Shop? shop;
  Product? product;
  bool isInProgress = false;
  bool addingIntoCart = false;
  List<int>? ratingList;
  int? maxRating;
  int selectedItem = 0;
  List<AppData>? appdata;

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? timerAnimation;

  @override
  void initState() {
    getAppData();
    super.initState();
    _getProductDetail();
    _getShopData();
  }

  @override
  void dispose() {
    super.dispose();
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

  _getProductDetail() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Product> myResponse =
        await ProductController.getSingleProduct(widget.productId);
    if (myResponse.success) {
      product = myResponse.data;
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

  _toggleFavorite() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse myResponse =
        await FavoriteController.toggleFavorite(product!.id);
    if (myResponse.success) {
      product!.isFavorite =
          TextUtils.parseBool(myResponse.data['is_favorite'].toString());
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

  addTimers(int totalPages) {
    if (timerAnimation == null) {
      timerAnimation = Timer.periodic(Duration(seconds: 5), (Timer timer) {
        if (_currentPage < totalPages - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        }
      });
    }
  }

  List<Widget> _buildPageIndicatorAnimated(
      int totalPages, ThemeData? themeData) {
    List<Widget> list = [];
    if (totalPages > 1) {
      addTimers(totalPages);

      for (int i = 0; i < totalPages; i++) {
        list.add(i == _currentPage
            ? _indicator(true, themeData)
            : _indicator(false, themeData));
      }
    } else {
      list.add(Container());
    }
    return list;
  }

  Widget _indicator(bool isActive, ThemeData? themeData) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInToLinear,
      margin: Spacing.horizontal(4),
      height: MySize.size8,
      width: MySize.size8,
      decoration: BoxDecoration(
        color: isActive
            ? themeData!.colorScheme.onBackground
            : themeData!.colorScheme.onBackground.withAlpha(140),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }

  _buildProductItems() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: Spacing.left(16),
              child: ProductUtils.singleProductItemOption(
                  product!.productItems![selectedItem],
                  themeData,
                  customAppTheme),
            ),
          ),
          PopupMenuButton(
            key: _productItemSelectKey,
            icon: Icon(
              MdiIcons.chevronDown,
              color: themeData!.colorScheme.onBackground,
              size: MySize.size20,
            ),
            onSelected: (dynamic value) async {
              setState(() {
                selectedItem = value;
              });
            },
            itemBuilder: (BuildContext context) {
              var list = <PopupMenuEntry<Object>>[];
              for (int i = 0; i < product!.productItems!.length; i++) {
                list.add(PopupMenuItem(
                  value: i,
                  child: Container(
                      margin: Spacing.vertical(2),
                      child: ProductUtils.singleProductItemOption(
                          product!.productItems![i],
                          themeData,
                          customAppTheme)),
                ));
                list.add(
                  PopupMenuDivider(
                    height: 10,
                  ),
                );
              }
              return list;
            },
            color: themeData!.backgroundColor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
        builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
      themeData = AppTheme.getThemeFromThemeMode(value.themeMode());
      customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
      return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, product);
          return false;
        },
        child: MaterialApp(
          scaffoldMessengerKey: _scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
          home: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: customAppTheme!.bgLayer1,
              elevation: 0,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context, product);
                },
                child: Icon(MdiIcons.chevronLeft),
              ),
              centerTitle: true,
              title: Text(product != null ? product!.name! : "Loading...",
                  style: AppTheme.getTextStyle(
                      themeData!.appBarTheme.textTheme!.headline6,
                      fontWeight: 600)),
            ),
            backgroundColor: customAppTheme!.bgLayer1,
            body: Container(
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
                  Expanded(child: buildBody()),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  buildBody() {
    if (product != null) {
      List<Widget> carouselItems = [];
      if (product!.productImages!.length != 0) {
        for (ProductImage productImage in product!.productImages!) {
          carouselItems.add(Container(
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ImagesScreen(
                              productId: product!.id,
                            )),
                  );
                },
                child: Image.network(
                  productImage.url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ));
        }
      } else {
        carouselItems.add(Image.asset(
          Product.getPlaceholderImage(),
        ));
      }
      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: Spacing.zero,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: PageView(
                    pageSnapping: true,
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: carouselItems,
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicatorAnimated(
                        product!.productImages!.length, themeData),
                  ),
                ),
                Container(
                  margin: Spacing.fromLTRB(16, 16, 16, 0),
                  padding: Spacing.all(16),
                  decoration: BoxDecoration(
                      color: customAppTheme!.bgLayer1,
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size4!)),
                      border: Border.all(
                          color: customAppTheme!.bgLayer4, width: 1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          product!.name!,
                          style: AppTheme.getTextStyle(
                              themeData!.textTheme.bodyText1,
                              color: themeData!.colorScheme.onBackground),
                        ),
                      ),
                      Container(
                        margin: Spacing.top(2),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ShopScreen(
                                          shopId: product!.shopId,
                                        )));
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                MdiIcons.storeOutline,
                                color: appdata == null
                                    ? Colors.purple
                                    : HexColor(appdata!.first.mainColor),
                                size: MySize.size20,
                              ),
                              Container(
                                margin: Spacing.left(8),
                                child: Text(
                                  product!.shop!.name,
                                  style: AppTheme.getTextStyle(
                                      themeData!.textTheme.bodyText2,
                                      color: themeData!.colorScheme.primary,
                                      fontWeight: 500),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        margin: Spacing.top(4),
                        child: Product.offerTextWidget(
                          originalPrice: product!
                              .productItems![selectedItem].price
                              .toDouble(),
                          offer: product!.offer,
                          fontSize: 20,
                          customAppTheme: customAppTheme,
                          themeData: themeData,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: Spacing.fromLTRB(16, 16, 16, 0),
                  padding: Spacing.all(0),
                  decoration: BoxDecoration(
                      color: customAppTheme!.bgLayer1,
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size4!)),
                      border: Border.all(
                          color: customAppTheme!.bgLayer4, width: 1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: Spacing.fromLTRB(16, 16, 16, 0),
                        child: Text(
                          Translator.translate("description"),
                          style: AppTheme.getTextStyle(
                              themeData!.textTheme.caption,
                              color: themeData!.colorScheme.onBackground,
                              fontWeight: 600),
                        ),
                      ),
                      Container(
                        margin: Spacing.fromLTRB(16, 0, 16, 0),
                        child: Html(
                          shrinkWrap: true,
                          data: product!.description,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: Spacing.fromLTRB(16, 16, 16, 16),
                  padding: Spacing.all(0),
                  decoration: BoxDecoration(
                      color: customAppTheme!.bgLayer1,
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size4!)),
                      border: Border.all(
                          color: customAppTheme!.bgLayer4, width: 1)),
                  child: _buildProductItems(),
                ),
                Container(
                  margin: Spacing.fromLTRB(16, 16, 16, 16),
                  padding: Spacing.all(0),
                  decoration: BoxDecoration(
                      color: customAppTheme!.bgLayer1,
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySize.size4!)),
                      border: Border.all(
                          color: customAppTheme!.bgLayer4, width: 1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                )
              ],
            ),
          ),
          _makeBottomBar()
        ],
      );
    } else if (isInProgress) {
      return LoadingScreens.getProductLoadingScreen(
          context, themeData, customAppTheme!);
    } else {
      return Center(
        child: Text("Something wrong"),
      );
    }
  }

  _getShopData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }
    MyResponse<Shop> myResponse =
        await ShopController.getSingleShop(product!.shopId);
    if (myResponse.success) {
      shop = myResponse.data;
      log(shop.toString());
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

  void launchWhatsapp({required number, message}) async {
    String wUrl = "whatsapp://send?phone=$number&text=$message";
    await canLaunch(wUrl) ? launch(wUrl) : print("Can't open whatsapp!");
  }

  void _launchCaller({required shopId}) async {
    MyResponse<Shop> tyResponse = await ShopController.getSingleShop(shopId);
    var url = tyResponse.data!.mobile;
    UrlUtils.callFromNumber(url);
  }

  _makeBottomBar() {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: customAppTheme!.shadowColor,
                blurRadius: MySize.size2!,
                offset: Offset(0, 0))
          ],
          border: Border.all(color: customAppTheme!.bgLayer4, width: 1),
          color: customAppTheme!.bgLayer1,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(MySize.size16!),
              topRight: Radius.circular(MySize.size16!))),
      padding: Spacing.symmetric(vertical: 16, horizontal: 16),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              onTap: () {
                _toggleFavorite();
              },
              child: Container(
                padding:
                    EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                decoration: BoxDecoration(
                    color: appdata == null
                        ? Colors.purple
                        : HexColor(appdata!.first.secondColor),
                    borderRadius:
                        BorderRadius.all(Radius.circular(MySize.size8!))),
                child: Icon(
                  product!.isFavorite ? MdiIcons.heart : MdiIcons.heartOutline,
                  size: MySize.size34,
                  color: appdata == null
                      ? Colors.white
                      : HexColor(appdata!.first.mainColor),
                  //color: Colors.white,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                launchWhatsapp(number: shop?.mobile);
              },
              child: Container(
                padding:
                    EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                decoration: BoxDecoration(
                    color: appdata == null
                        ? Colors.purple
                        : HexColor(appdata!.first.secondColor),
                    borderRadius:
                        BorderRadius.all(Radius.circular(MySize.size8!))),
                child: Icon(
                  MdiIcons.whatsapp,
                  size: MySize.size34,
                  color: appdata == null
                      ? Colors.purple
                      : HexColor(appdata!.first.mainColor),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _launchCaller(shopId: product!.shopId);
              },
              child: Container(
                padding:
                    EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                decoration: BoxDecoration(
                    color: appdata == null
                        ? Colors.purple
                        : HexColor(appdata!.first.secondColor),
                    borderRadius:
                        BorderRadius.all(Radius.circular(MySize.size8!))),
                child: Icon(
                  MdiIcons.phoneOutline,
                  size: MySize.size34,
                  color: appdata == null
                      ? Colors.purple
                      : HexColor(appdata!.first.mainColor),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
