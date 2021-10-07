import 'dart:async';
import 'dart:developer';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitrinint/AppTheme.dart';
import 'package:vitrinint/AppThemeNotifier.dart';
import 'package:vitrinint/api/api_util.dart';
import 'package:vitrinint/api/currency_api.dart';
import 'package:vitrinint/controllers/CartController.dart';
import 'package:vitrinint/controllers/FavoriteController.dart';
import 'package:vitrinint/controllers/ProductController.dart';
import 'package:vitrinint/controllers/ShopController.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'StoryScreen.dart';

class ImagesScreen extends StatefulWidget {
  final int productId;

  const ImagesScreen({Key? key, required this.productId}) : super(key: key);
  @override
  _ImagesScreenState createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  //Theme Data
  ThemeData? themeData;
  CustomAppTheme? customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();
  final GlobalKey _productItemSelectKey = new GlobalKey();

  //Other Variables
  Shop? shop;
  Product? product;
  bool isInProgress = false;
  bool addingIntoCart = false;
  List<int>? ratingList;
  int? maxRating;
  int selectedItem = 0;

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? timerAnimation;

  @override
  void initState() {
    super.initState();
    _getProductDetail();
    _getShopData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getProductDetail() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Product> myResponse = await ProductController.getSingleProduct(widget.productId);
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
                    ))),
          );
        });
  }

  buildBody() {
    if (product != null) {
      List<Widget> carouselItems = [];
      if (product!.productImages!.length != 0) {
        return PhotoViewGallery.builder(
          itemCount: product!.productImages!.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(
                product!.productImages![index].url,
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
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / 3,
              ),
            ),
          ),
        );
      } else {
        carouselItems.add(Image.asset(
          Product.getPlaceholderImage(),
        ));
      }
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
    MyResponse<Shop> myResponse = await ShopController.getSingleShop(product!.shopId);
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

  void showMessage({String message = "Something wrong", Duration? duration}) {
    if (duration == null) {
      duration = Duration(seconds: 1);
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
}
