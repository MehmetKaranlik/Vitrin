import 'package:hexcolor/hexcolor.dart';
import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import '../api/api_util.dart';
import '../controllers/AppDataController.dart';
import '../controllers/FavoriteController.dart';
import '../models/AppData.dart';
import '../models/Favorite.dart';
import '../models/MyResponse.dart';
import '../models/Product.dart';
import '../services/AppLocalizations.dart';
import '../utils/SizeConfig.dart';
import 'ProductScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'LoadingScreens.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  //Theme Data
  ThemeData? themeData;
  CustomAppTheme? customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  double findAspectRatio(double width) {
    //Logic for aspect ratio of grid view
    return (width / 2 - MySize.size24!) / ((width / 2 - MySize.size24!) + 60);
  }

  //Other Variables
  bool isInProgress = false;
  List<Favorite>? favorites = [];
  List<AppData>? appdata;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
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

  _loadFavoriteProducts() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<Favorite>> myResponse =
        await FavoriteController.getAllFavorite();

    if (myResponse.success) {
      favorites = myResponse.data;
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
    _loadFavoriteProducts();
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
                backgroundColor: customAppTheme!.bgLayer1,
                key: _scaffoldKey,
                appBar: AppBar(
                  backgroundColor: customAppTheme!.bgLayer1,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(Translator.translate("favorites"),
                      style: AppTheme.getTextStyle(
                          themeData!.appBarTheme.textTheme!.headline6,
                          fontWeight: 600)),
                ),
                body: RefreshIndicator(
                  onRefresh: _refresh,
                  backgroundColor: customAppTheme!.bgLayer1,
                  color: themeData!.colorScheme.primary,
                  key: _refreshIndicatorKey,
                  child: ListView(
                    padding: Spacing.zero,
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
                      _buildBody()
                    ],
                  ),
                )));
      },
    );
  }

  Widget _buildBody() {
    if (favorites!.length != 0) {
      return Container(child: _showProducts(favorites!));
    } else if (isInProgress) {
      return Container(
          child: LoadingScreens.getFavouriteLoadingScreen(
              context, themeData!, customAppTheme!,
              itemCount: 5));
    } else {
      return Center(
        child: Text(
          Translator.translate("you_have_not_favorite_item_yet"),
          style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
              color: themeData!.colorScheme.onBackground, fontWeight: 500),
        ),
      );
    }
  }

  _showProducts(List<Favorite> favorites) {
    List<Widget> listWidgets = [];

    for (int i = 0; i < favorites.length; i++) {
      listWidgets.add(InkWell(
        onTap: () async {
          Product? newProduct = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductScreen(
                        productId: favorites[i].product!.id,
                      )));
          if (newProduct != null) {
            setState(() {
              favorites[i].product = newProduct;
            });
          }
        },
        child: Container(
          margin: Spacing.bottom(16),
          child: _singleProduct(favorites[i].product!),
        ),
      ));
    }

    return GridView.count(
      padding: Spacing.fromLTRB(16, 16, 16, 0),
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: findAspectRatio(MediaQuery.of(context).size.width),
      mainAxisSpacing: 0,
      crossAxisSpacing: MySize.size16!,
      children: listWidgets,
    );
  }

  _singleProduct(Product product) {
    return Stack(
      children: [
        Container(
          padding: Spacing.fromLTRB(7, 7, 7, 3),
          margin: Spacing.zero,
          decoration: BoxDecoration(
            color: customAppTheme!.bgLayer1,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: customAppTheme!.bgLayer4),
            boxShadow: [
              BoxShadow(
                color: customAppTheme!.shadowColor,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: product.productImages!.length != 0
                    ? _buildProductImage(product)
                    : _buildProductPlaceHolder(),
              ),
              Spacing.height(0),
              Text(
                product.name!,
                style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
                    fontWeight: 600, letterSpacing: 0),
                overflow: TextOverflow.ellipsis,
              ),
              Spacing.height(1),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildProductOption(product),
                    Product.offerTextWidget(
                      originalPrice: product.productItems![0].price.toDouble(),
                      offer: product.offer,
                      fontSize: 13,
                      customAppTheme: customAppTheme,
                      themeData: themeData,
                    ),
                  ]),
            ],
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Icon(
            product.isFavorite ? MdiIcons.heart : MdiIcons.heartOutline,
            color: product.isFavorite
                ? appdata == null
                    ? Colors.purple
                    : HexColor(appdata!.first.mainColor)
                : appdata == null
                    ? Colors.purple
                    : HexColor(appdata!.first.secondColor),
            size: 22,
          ),
        )
      ],
    );
  }

  Text _buildProductOption(Product product) {
    return Text(
      product.productItems!.length.toString() +
          " " +
          Translator.translate("options"),
      style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
          fontWeight: 500),
    );
  }

  Image _buildProductPlaceHolder() {
    return Image.asset(
      Product.getPlaceholderImage(),
      width: MediaQuery.of(context).size.width * 0.35,
      fit: BoxFit.contain,
    );
  }

  Image _buildProductImage(Product product) {
    return Image.network(
      product.productImages![0].url,
      loadingBuilder:
          (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return LoadingScreens.getSimpleImageScreen(
              context, themeData, customAppTheme!,
              width: MediaQuery.of(context).size.height * 0.25,
              height: MediaQuery.of(context).size.width * 0.30);
        }
      },
      width: MediaQuery.of(context).size.width * 0.30,
      height: MediaQuery.of(context).size.height * 0.25,
      fit: BoxFit.fitHeight,
    );
  }
}
