import 'package:vitrinint/models/ProductItem.dart';
import 'package:vitrinint/models/ProductItemFeature.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../AppTheme.dart';
import 'ColorUtils.dart';
import 'SizeConfig.dart';

class ProductUtils{


  static singleProductItemOption(ProductItem productItem, ThemeData? themeData,
      CustomAppTheme? customAppTheme) {
    List<Widget> _list = [];
    List<ProductItemFeature> productItemFeatures =
        productItem.productItemFeatures;
    for (int i = 0; i < productItemFeatures.length; i++) {
      ProductItemFeature productItemFeature = productItemFeatures[i];
      if (productItemFeature.feature.toLowerCase().compareTo('color') == 0) {
        _list.add(Container(
          width: MySize.size20,
          height: MySize.size20,
          decoration: BoxDecoration(
              color: ColorUtils.fromHex(productItemFeature.value),
              shape: BoxShape.circle),
        ));
      }else if(productItemFeature.feature.toLowerCase().compareTo('size')==0){
        _list.add(
            Container(
              width: MySize.getScaledSizeHeight(32),
              height: MySize.getScaledSizeHeight(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: customAppTheme!.bgLayer4, width: 1.6),
                color: customAppTheme.bgLayer2,
              ),
              child: Center(
                child: Text(
                  productItemFeature.value.toString(),
                  style: AppTheme.getTextStyle(themeData!.textTheme.bodyText1,
                  letterSpacing: -0.2,
                  fontWeight: 600,
                  color: themeData.colorScheme.onBackground),
                ),
              ),
            )
        );
      }else if(productItemFeature.feature.toLowerCase().compareTo('gram')==0){
        _list.add(
            Container(
              padding: Spacing.fromLTRB(16,8,16,8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: customAppTheme!.bgLayer4, width: 1.6),
                color: customAppTheme.bgLayer2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    productItemFeature.value.toString(),
                    style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
                    letterSpacing: -0.2,
                    fontWeight: 600,
                    color: themeData.colorScheme.onBackground),
                  ),
                  SizedBox(width: MySize.size4,),
                  Icon(MdiIcons.weightGram,size: MySize.size16,color: themeData.colorScheme.onBackground,)
                ],
              ),
            )
        );
      }
      else {
        _list.add(Container(
          child: Text(productItemFeature.value, style: AppTheme.getTextStyle(
              themeData!.textTheme.bodyText2,
                color: themeData.colorScheme.onBackground),),
        ));
      }

      if(i!=productItemFeatures.length-1){
        _list.add(SizedBox(width: MySize.size16,));
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