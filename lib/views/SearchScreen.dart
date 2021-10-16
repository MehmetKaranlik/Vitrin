import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:vitrinint/controllers/search_view_drawer_controller.dart';
import 'package:vitrinint/widgets/sized_place_holder.dart';
import '../AppTheme.dart';
import '../AppThemeNotifier.dart';
import '../api/api_util.dart';
import '../controllers/AppDataController.dart';
import '../controllers/CategoryController.dart';
import '../controllers/ProductController.dart';
import '../models/AppData.dart';
import '../models/Category.dart';
import '../models/Filter.dart';
import '../models/MyResponse.dart';
import '../models/Product.dart';
import '../models/Stories.dart';
import '../models/SubCategory.dart';
import '../services/AppLocalizations.dart';
import '../utils/SizeConfig.dart';
import 'CategoryProductScreen.dart';
import 'LoadingScreens.dart';
import 'ProductScreen.dart';

class SearchScreen extends StatefulWidget {
  final String? mainColor;
  final String? secondColor;
  SearchScreen({Key? key, this.mainColor, this.secondColor}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //Theme Data
  ThemeData? themeData;
  CustomAppTheme? customAppTheme;
  bool? isSliderActive;
  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;
  List<bool> _dataExpansionPanel = [true];
  List<Product>? products = [];
  List<Category>? categories = [];
  List<Stories>? stories = [];
  List<AppData>? appdata;

  double findAspectRatio(double width) {
    //Logic for aspect ratio of grid view
    return (width / 2 - MySize.size24!) / ((width / 2 - MySize.size24!) + 60);
  }

  //Filter Variable
  Filter filter = Filter();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      getAppData();
      _filterProductData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Pull to refresh call this function
  Future<void> _refresh() async {
    _filterProductData();
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

  //Get all filter product data
  _filterProductData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<Product>> myResponseProduct =
        await ProductController.getFilteredProduct(filter);

    if (myResponseProduct.success) {
      print(ApiUtil.MAIN_API_URL_DEV + ApiUtil.PRODUCTS);
      print(myResponseProduct.data);
      products = myResponseProduct.data;
    } else {
      if (mounted) {
        ApiUtil.checkRedirectNavigation(
            context, myResponseProduct.responseCode);
        showMessage(message: myResponseProduct.errorText);
      }
    }

    if (categories!.length == 0) {
      MyResponse<List<Category>> myResponseCategory =
          await CategoryController.getAllCategory();
      if (myResponseCategory.success) {
        categories = myResponseCategory.data;
      } else {
        if (mounted) {
          ApiUtil.checkRedirectNavigation(
              context, myResponseCategory.responseCode);
          showMessage(message: myResponseCategory.errorText);
        }
      }
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  _clearFilter() {
    setState(() {
      DrawerOptionsController().clearAllData();
    });
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
                  backgroundColor: customAppTheme!.bgLayer1,
                  resizeToAvoidBottomInset: false,
                  endDrawer: _endDrawer(),
                  key: _scaffoldKey,
                  body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme!.bgLayer1,
                    color: themeData!.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: Column(
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
                        Expanded(
                            child: Column(
                          children: [
                            searchBar(),
                            _categoriesWidget(categories!),
                            //_storiesWidget(stories!),
                            Expanded(child: buildBody()),
                          ],
                        ))
                      ],
                    ),
                  )),
            ));
      },
    );
  }

  _categoriesWidget(List<Category> categories) {
    List<Widget> list = [];
    for (Category category in categories) {
      list.add(InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CategoryProductScreen(
                          category: category,
                        )));
          },
          child: _singleCategory(category)));
      list.add(SizedBox(width: MySize.size24));
    }
    return Container(
      margin: Spacing.fromLTRB(24, 16, 0, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: list,
        ),
      ),
    );
  }

  _singleCategory(Category category) {
    return Container(
      child: Column(
        children: <Widget>[
          ClipOval(
            child: Container(
              height: MySize.size60,
              width: MySize.size60,
              color: appdata == null
                  ? themeData!.colorScheme.primary
                  : HexColor(appdata!.first.secondColor),
              child: Center(
                child: Image.network(
                  category.imageUrl,
                  color: appdata == null
                      ? themeData!.colorScheme.primary
                      : HexColor(appdata!.first.mainColor),
                  width: MySize.getScaledSizeWidth(28),
                  height: MySize.getScaledSizeWidth(28),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: Spacing.top(8),
            child: Text(
              category.title,
              style: AppTheme.getTextStyle(themeData?.textTheme.caption,
                  fontWeight: 600, letterSpacing: 0),
            ),
          )
        ],
      ),
    );
  }

  Widget buildBody() {
    if (products!.length != 0) {
      return Container(margin: Spacing.top(4), child: _showProducts(products!));
    } else if (isInProgress) {
      return Container(
          margin: Spacing.top(16),
          child: LoadingScreens.getSearchLoadingScreen(
              context, themeData!, customAppTheme!,
              itemCount: 5));
    } else {
      return Center(
          child: Container(
              margin: Spacing.top(16),
              child: Text(
                Translator.translate("there_is_no_product_with_this_filter"),
              )));
    }
  }

  List<Product> priceFilteredProductList = [];
  _showProducts(List<Product> products) {
    List<Widget> listWidgets = [];

    for (int i = 0;
        isSliderActive == true
            ? i < priceFilteredProductList.length
            : i < products.length;
        i++) {
      listWidgets.add(
        InkWell(
          onTap: () async {
            Product? newProduct = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductScreen(
                  productId: isSliderActive == true
                      ? priceFilteredProductList[i].shopId
                      : products[i].shopId,
                ),
              ),
            );
            if (newProduct != null) {
              setState(
                () {
                  isSliderActive == true
                      ? priceFilteredProductList[i] = newProduct
                      : products[i] = newProduct;
                },
              );
            }
          },
          child: Container(
            margin: Spacing.bottom(16),
            child: _singleProduct(isSliderActive == true
                ? priceFilteredProductList[i]
                : products[i]),
          ),
        ),
      );
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
          padding: Spacing.fromLTRB(7, 7, 7, 5),
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
              Spacing.height(2),
              _buildProductName(product),
              Spacing.height(3),
              _buildProductBottom(product),
            ],
          ),
        ),
        _buildFavoriteIcon(product)
      ],
    );
  }

  Text _buildProductName(Product product) {
    return Text(
      product.name!,
      style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
          fontWeight: 600, letterSpacing: 0),
      overflow: TextOverflow.ellipsis,
    );
  }

  Row _buildProductBottom(Product product) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildProductOptions(product),
          Product.offerTextWidget(
            originalPrice: product.productItems![0].price.toDouble(),
            offer: product.offer,
            fontSize: 13,
            customAppTheme: customAppTheme,
            themeData: themeData,
          ),
        ]);
  }

  Positioned _buildFavoriteIcon(Product product) {
    return Positioned(
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
    );
  }

  Text _buildProductOptions(Product product) {
    return Text(
      product.productItems!.length.toString() +
          " " +
          Translator.translate("options"),
      style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
          fontWeight: 500),
      overflow: TextOverflow.ellipsis,
    );
  }

  Image _buildProductPlaceHolder() {
    return Image.asset(
      Product.getPlaceholderImage(),
      width: MediaQuery.of(context).size.width * 0.35,
      height: MediaQuery.of(context).size.width * 0.40,
      fit: BoxFit.contain,
    );
  }

  CachedNetworkImage _buildProductImage(Product product) {
    return CachedNetworkImage(
      imageUrl: product.productImages![0].url,
      placeholder: (ctx, url) => LoadingScreens.getSimpleImageScreen(
          context, themeData, customAppTheme!,
          width: MediaQuery.of(context).size.width * 0.35,
          height: MediaQuery.of(context).size.width * 0.40),
      errorWidget: (ctx, url, error) => Icon(
        Icons.error,
        color: Colors.red,
      ),
      width: MediaQuery.of(context).size.width * 0.35,
      height: MediaQuery.of(context).size.width * 0.40,
    );
    /*return Image.network(
      product.productImages![0].url,
      
      
      loadingBuilder:
          (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return LoadingScreens.getSimpleImageScreen(
              context, themeData, customAppTheme!,
              width: MediaQuery.of(context).size.width * 0.35,
              height: MediaQuery.of(context).size.width * 0.40);
        }
      },
      width: MediaQuery.of(context).size.width * 0.35,
      height: MediaQuery.of(context).size.width * 0.40,
      fit: BoxFit.fitHeight,
    );*/
  }

  Widget searchBar() {
    return Padding(
        padding: Spacing.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                style: AppTheme.getTextStyle(themeData!.textTheme.subtitle2,
                    letterSpacing: 0, fontWeight: 500),
                decoration: InputDecoration(
                  //hintText: appdata!.first.mainColor.toString(),
                  hintText: Translator.translate("search"),
                  hintStyle: AppTheme.getTextStyle(
                      themeData!.textTheme.subtitle2,
                      letterSpacing: 0,
                      fontWeight: 500),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: themeData!.colorScheme.background,
                  prefixIcon: Icon(
                    MdiIcons.magnify,
                    size: 22,
                    color: themeData!.colorScheme.onBackground.withAlpha(200),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.only(right: 16),
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (value) {
                  filter.name = value;
                  _filterProductData();
                },
              ),
            ),
            InkWell(
              onTap: () {
                _scaffoldKey.currentState!.openEndDrawer();
              },
              child: Container(
                margin: EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: customAppTheme!.bgLayer1,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: customAppTheme!.bgLayer4),
                  boxShadow: [
                    BoxShadow(
                      color: customAppTheme!.shadowColor,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                padding: Spacing.all(12),
                child: Icon(
                  MdiIcons.tune,
                  color: appdata == null
                      ? themeData!.colorScheme.primary
                      : HexColor(appdata!.first.mainColor),
                  size: 22,
                ),
              ),
            ),
          ],
        ));
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

  _filterPriceFilteredProduct(value) {
    for (var i = 0; i < products!.length; i++) {
      if (products![i].productItems![0].price < value) {
        priceFilteredProductList.add(products![i]);
      }
    }
  }

  _endDrawer() {
    bool _princeAscending = false;
    bool _princeDescending = false;
    bool _distanceAscending = false;
    bool _distanceDescending = false;
    double _sliderValue = 0;
    if (DrawerOptionsController().getSliderValue() != 0 &&
        DrawerOptionsController().getSliderValue() != null) {
      _sliderValue = DrawerOptionsController().getSliderValue();
    }
    if (DrawerOptionsController().getAscendingPriceValue() == true &&
        DrawerOptionsController().getAscendingPriceValue() != null) {
      _princeAscending = DrawerOptionsController().getAscendingPriceValue();
    }
    if (DrawerOptionsController().getDescendingPriceValue() == true &&
        DrawerOptionsController().getDescendingPriceValue() != null) {
      _princeDescending = DrawerOptionsController().getDescendingPriceValue();
    }
    if (DrawerOptionsController().getDescendingDistanceValue() == true &&
        DrawerOptionsController().getDescendingDistanceValue() != null) {
      _distanceDescending = DrawerOptionsController().getDescendingPriceValue();
    }
    if (DrawerOptionsController().getAscendingDistanceValue() == true &&
        DrawerOptionsController().getAscendingDistanceValue() != null) {
      _distanceAscending =
          DrawerOptionsController().getAscendingDistanceValue();
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      color: themeData!.backgroundColor,
      child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translator.translate("filter").toUpperCase(),
                  style: AppTheme.getTextStyle(themeData!.textTheme.subtitle1,
                      fontWeight: 700,
                      color: appdata == null
                          ? Colors.purple
                          : HexColor(appdata!.first.mainColor)),
                ),
                InkWell(
                  onTap: () {
                    _clearFilter();
                  },
                  child: Text(
                    Translator.translate("clear"),
                    style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
                        fontWeight: 500,
                        color: themeData!.colorScheme.onBackground),
                  ),
                ),
              ],
            ),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return Container(
                margin: Spacing.top(15.w),
                child: Row(children: [
                  Material(
                    child: Slider(
                      inactiveColor: themeData!.colorScheme.onBackground,
                      divisions: 50,
                      min: 0,
                      max: 1000,
                      label: "Fiyat",
                      value: _sliderValue,
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                        });
                      },
                    ),
                  ),
                  Ink(
                      color: Colors.red,
                      child: Text("₺" + _sliderValue.toString())),
                ]),
              );
            },
          ),
          Container(
            margin: Spacing.top(5.w),
            child: Row(
              children: [
                SizedPlaceHolder(
                    color: Colors.transparent, height: 0, width: 42.w),
                Text("Artan"),
                SizedPlaceHolder(
                    color: Colors.transparent, height: 0, width: 3.w),
                Text("Azalan"),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            margin: Spacing.top(0.w),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Fiyata Göre Sırala"),
                    SizedPlaceHolder(
                        color: Colors.transparent, height: 0, width: 6.w),
                    Checkbox(
                        visualDensity: VisualDensity.compact,
                        activeColor: themeData!.colorScheme.primary,
                        value: _princeAscending,
                        onChanged: (bool? value) {
                          setState(() {
                            _princeAscending = value!;
                            _princeDescending = false;
                          });
                        }),
                    Checkbox(
                        visualDensity: VisualDensity.compact,
                        activeColor: themeData!.colorScheme.primary,
                        value: _princeDescending,
                        onChanged: (bool? value) {
                          setState(() {
                            _princeDescending = value!;
                            _princeAscending = false;
                          });
                        }),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            margin: Spacing.top(5.w),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Uzaklığa göre sırala"),
                    SizedPlaceHolder(
                        color: Colors.transparent, height: 0, width: 3.w),
                    Checkbox(
                        visualDensity: VisualDensity.compact,
                        value: _distanceAscending,
                        activeColor: themeData!.colorScheme.primary,
                        onChanged: (bool? value) {
                          setState(() {
                            _distanceAscending = value!;
                            _distanceDescending = false;
                          });
                        }),
                    Checkbox(
                        visualDensity: VisualDensity.compact,
                        value: _distanceDescending,
                        activeColor: themeData!.colorScheme.primary,
                        onChanged: (bool? value) {
                          setState(() {
                            _distanceDescending = value!;
                            _distanceAscending = false;
                          });
                        })
                  ],
                );
              },
            ),
          ),
          Container(
            margin: Spacing.fromLTRB(20, 8, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translator.translate("only_offer"),
                  style: AppTheme.getTextStyle(themeData!.textTheme.bodyText1,
                      color: themeData!.colorScheme.onBackground,
                      fontWeight: 600),
                ),
                Switch(
                    value: filter.isInOffer,
                    onChanged: (value) {
                      setState(() {
                        filter.setIsInOffer(value);
                      });
                    })
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(24),
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    boxShadow: [
                      BoxShadow(
                        color: themeData!.colorScheme.primary.withAlpha(24),
                        blurRadius: 3,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            appdata == null
                                ? Colors.purple
                                : HexColor(appdata!.first.mainColor)),
                        padding: MaterialStateProperty.all(Spacing.xy(24, 12)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ))),
                    onPressed: () {
                      DrawerOptionsController().saveSliderValue(_sliderValue);
                      DrawerOptionsController()
                          .saveAscendingPriceValue(_princeAscending);
                      DrawerOptionsController()
                          .saveDescendingPriceValue(_princeDescending);
                      DrawerOptionsController()
                          .saveAscendingDistanceValue(_distanceAscending);
                      DrawerOptionsController()
                          .saveDescendingDistanceValue(_distanceDescending);
                      if (_sliderValue != 0) {
                        priceFilteredProductList.clear();
                        _filterPriceFilteredProduct(_sliderValue);
                        setState(() {
                          isSliderActive = true;
                        });
                        if (_princeAscending == true) {
                          this.priceFilteredProductList.sort((b, a) => b
                              .productItems![0].price
                              .compareTo(a.productItems![0].price));
                        }
                        if (_princeDescending == true) {
                          this.priceFilteredProductList.sort((b, a) => a
                              .productItems![0].price
                              .compareTo(b.productItems![0].price));
                        }
                      }
                      _scaffoldKey.currentState!.openDrawer();
                      if (_sliderValue == 0 && _princeAscending == true) {
                        setState(() {
                          this.products!.sort((b, a) => b.productItems![0].price
                              .compareTo(a.productItems![0].price));
                        });
                      }
                      if (_sliderValue == 0 && _princeDescending == true) {
                        setState(() {
                          this.products!.sort((b, a) => a.productItems![0].price
                              .compareTo(b.productItems![0].price));
                        });
                      }
                      if (_sliderValue == 0) {
                        setState(() {
                          isSliderActive = false;
                        });
                      }
                    },
                    child: Text(
                      Translator.translate("apply").toUpperCase(),
                      style: AppTheme.getTextStyle(
                          themeData!.textTheme.bodyText2,
                          fontWeight: 600,
                          color: themeData!.colorScheme.onPrimary,
                          letterSpacing: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget categoryFilterList() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text("data"),
    );
  }
}
