import 'dart:developer';

import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitrinint/views/AppScreen.dart';
import 'package:vitrinint/views/HomeScreen.dart';
import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import '../api/api_util.dart';
import '../api/currency_api.dart';
import '../controllers/AppDataController.dart';
import '../controllers/ShopController.dart';
import '../models/AppData.dart';
import '../models/MyResponse.dart';
import '../models/Product.dart';
import '../models/Shop.dart';
import '../services/AppLocalizations.dart';
import '../utils/SizeConfig.dart';
import '../utils/UrlUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'LoadingScreens.dart';
import 'ProductScreen.dart';

class ShopScreen extends StatefulWidget {
  final int? shopId;

  const ShopScreen({Key? key, this.shopId}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  //ThemeData
  ThemeData? themeData;
  late CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  double findAspectRatio(double width) {
    //Logic for aspect ratio of grid view
    return (width / 2 - 24) / ((width / 2 - 24) + 60);
  }

  //Other variables
  Shop? shop;
  bool isInProgress = false;
  List<AppData>? appdata;

  @override
  void initState() {
    getAppData();
    super.initState();
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

  _getShopData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Shop> myResponse =
        await ShopController.getSingleShop(widget.shopId);

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

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
        builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
      themeData = AppTheme.getThemeFromThemeMode(value.themeMode());
      customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
      return MaterialApp(
          scaffoldMessengerKey: _scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
          home: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                backgroundColor: customAppTheme.bgLayer1,
                elevation: 0,
                leading: InkWell(
                  onTap: () {
                    Get.off(() => AppScreen());
                  },
                  child: Icon(MdiIcons.chevronLeft),
                ),
                centerTitle: true,
                title: Text(
                    shop != null ? shop!.name : Translator.translate("loading"),
                    style: AppTheme.getTextStyle(
                        themeData!.appBarTheme.textTheme!.headline6,
                        fontWeight: 600)),
              ),
              backgroundColor: customAppTheme.bgLayer1,
              body: Container(
                child: ListView(
                  padding: Spacing.zero,
                  children: [
                    Container(
                      height: 3,
                      child: isInProgress
                          ? LinearProgressIndicator(
                              minHeight: 3,
                            )
                          : Container(
                              height: 3,
                            ),
                    ),
                    _buildBody()
                  ],
                ),
              )));
    });
  }

  _buildBody() {
    if (shop != null) {
      return _buildShop();
    } else {
      return Container();
    }
  }

  _buildShop() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Center(
              child: Image.network(
                shop!.imageUrl,
                width: MySize.safeWidth,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(10, 10, 10, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            appdata == null
                                ? Colors.purple
                                : HexColor(appdata!.first.mainColor)),
                        padding: MaterialStateProperty.all(Spacing.xy(6, 3)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ))),
                    onPressed: () {
                      UrlUtils.callFromNumber(shop!.mobile);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MdiIcons.phoneOutline,
                            size: 16, color: themeData!.colorScheme.onPrimary),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          Translator.translate("call_to_shop"),
                          style: AppTheme.getTextStyle(
                              themeData!.textTheme.bodyText2,
                              color: themeData!.colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            appdata == null
                                ? Colors.purple
                                : HexColor(appdata!.first.mainColor)),
                        padding: MaterialStateProperty.all(Spacing.xy(6, 3)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ))),
                    onPressed: () {
                      launchWhatsapp(number: shop!.mobile);
                      //UrlUtils.callFromNumber(shop!.mobile);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MdiIcons.whatsapp,
                            size: 16, color: themeData!.colorScheme.onPrimary),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          Translator.translate("whatsapp"),
                          style: AppTheme.getTextStyle(
                              themeData!.textTheme.bodyText2,
                              color: themeData!.colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            appdata == null
                                ? Colors.purple
                                : HexColor(appdata!.first.mainColor)),
                        padding: MaterialStateProperty.all(Spacing.xy(6, 3)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ))),
                    onPressed: () {
                      UrlUtils.openMap(shop!.latitude, shop!.longitude);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MdiIcons.mapMarkerOutline,
                            size: 16, color: themeData!.colorScheme.onPrimary),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          Translator.translate("go_to_shop"),
                          style: AppTheme.getTextStyle(
                              themeData!.textTheme.bodyText2,
                              color: themeData!.colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 16, 16, 0),
            padding: Spacing.all(8),
            decoration: BoxDecoration(
                color: customAppTheme.bgLayer1,
                borderRadius: BorderRadius.all(Radius.circular(4)),
                border: Border.all(color: customAppTheme.bgLayer4, width: 1)),
            child: Html(
              shrinkWrap: true,
              data: shop!.description,
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translator.translate("products"),
                  style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
                      color: themeData!.colorScheme.onBackground,
                      fontWeight: 600),
                ),
                Container(
                    margin: Spacing.top(16),
                    child: shop!.products.length != 0
                        ? _showProducts(shop!.products)
                        : Container(
                            child: Text("This shop doesn\'t have any product."),
                          ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  _showProducts(List<Product> products) {
    List<Widget> listWidgets = [];

    for (int i = 0; i < products.length; i++) {
      listWidgets.add(InkWell(
        onTap: () async {
          Product? newProduct = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductScreen(
                        productId: products[i].id,
                      )));
          if (newProduct != null) {
            setState(() {
              products[i] = newProduct;
            });
          }
        },
        child: Container(
          margin: Spacing.bottom(16),
          child: _singleProduct(products[i]),
        ),
      ));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: findAspectRatio(MediaQuery.of(context).size.width),
      mainAxisSpacing: 0,
      crossAxisSpacing: 16,
      children: listWidgets,
    );
  }

  _singleProduct(Product product) {
    return Stack(
      children: [
        Container(
          padding: Spacing.all(16),
          margin: Spacing.zero,
          decoration: BoxDecoration(
            color: customAppTheme.bgLayer1,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: customAppTheme.bgLayer4),
            boxShadow: [
              BoxShadow(
                color: customAppTheme.shadowColor,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: product.productImages!.length != 0
                    ? Image.network(
                        product.productImages![0].url,
                        loadingBuilder: (BuildContext ctx, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return LoadingScreens.getSimpleImageScreen(
                                context, themeData, customAppTheme,
                                width: 90, height: 90);
                          }
                        },
                        width: MediaQuery.of(context).size.width * 0.35,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        Product.getPlaceholderImage(),
                        width: MediaQuery.of(context).size.width * 0.35,
                        fit: BoxFit.fill,
                      ),
              ),
              Spacing.height(2),
              Text(
                product.name!,
                style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
                    fontWeight: 600, letterSpacing: 0),
                overflow: TextOverflow.ellipsis,
              ),
              Spacing.height(3),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      product.productItems!.length.toString() +
                          " " +
                          Translator.translate("options"),
                      style: AppTheme.getTextStyle(
                          themeData!.textTheme.bodyText2,
                          fontWeight: 500),
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
}
