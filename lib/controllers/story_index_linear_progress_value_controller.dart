import 'package:get/get.dart';

class LinearProgressValueController extends GetxController {
  final _currentValue = 0.000.obs;
  double get currentValue => _currentValue.value;
  set currentValue(double currentValue) => _currentValue.value = currentValue;
}
