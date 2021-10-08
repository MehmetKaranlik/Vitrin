import '../api/api_util.dart';
import 'SizeConfig.dart';
import 'package:flutter/material.dart';

class ImageUtils {
  static Widget getImageFromNetwork(String imageUrl,
      {double? height = 64, double? width = 64, BoxFit? fit = BoxFit.cover}) {
    String? url = getStorageUrl(imageUrl);
    if (url == null) {
      return Image.asset(
        getPlaceholderImage(),
        width: width,
        height: height,
        fit: fit,
      );
    }
    return Image.network(
      url,
      width: width,
      errorBuilder: (context, error, stack) {
        return Spacing.empty();
      },
      height: height,
      fit: fit,
    );
  }

  static String? getStorageUrl(String? url) {
    if (url == null || url.contains("null")) {
      return null;
    }

    if (url.contains('storage')) {
      return url;
    } else {
      return getImageUrl(url);
    }
  }

  static String getImageUrl(String url,
      {bool withoutStoragePrefix = true, bool withoutIPPrefix = true}) {
    if (withoutIPPrefix && withoutStoragePrefix) {
      return ApiUtil.BASE_URL + "storage/" + url;
    }
    return url;
  }

  static String getPlaceholderImage() {
    return './assets/images/placeholder/no-product-image.png';
  }
}
