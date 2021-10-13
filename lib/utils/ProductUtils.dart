import '../models/ProductItem.dart';
import '../models/ProductItemFeature.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../AppTheme.dart';
import 'ColorUtils.dart';
import 'SizeConfig.dart';

class ProductUtils {
  static singleProductItemOption(ProductItem productItem, ThemeData? themeData,
      CustomAppTheme? customAppTheme) {
    List<Widget> _list = [];

    List<ProductItemFeature> productItemFeatures =
        productItem.productItemFeatures;
    //print(productItem.productItemFeatures[0].feature);
    for (int i = 0; i < productItemFeatures.length; i++) {
      // print(0.toString() + productItemFeatures[0].toString());
      ProductItemFeature productItemFeature = productItemFeatures[i];
      print(productItem.productItemFeatures[0]);
      if (productItemFeature.feature.toLowerCase().compareTo('color') == 0) {
        _list.add(Container(
          width: MySize.size20,
          height: MySize.size20,
          decoration: BoxDecoration(
              color: ColorUtils.fromHex(productItemFeatures[0].value),
              shape: BoxShape.circle),
        ));
      }
    }

    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _list,
      ),
    );
  }
}
