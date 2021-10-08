import 'package:get/get.dart';

class CarouselIndexController extends GetxController {
  final _carouselIndex = 0.obs;
  int get carouselIndex => _carouselIndex.value;
  set carouselIndex(int currentIndex) => _carouselIndex.value = carouselIndex;
}
