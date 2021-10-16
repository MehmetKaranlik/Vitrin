import 'package:get_storage/get_storage.dart';

class DrawerOptionsController {
  final storage = GetStorage();
//----------------------------------- saving data ----------------------------//
  void saveSliderValue(double value) {
    storage.write("sliderValue", value);
  }

  void saveAscendingPriceValue(bool value) {
    storage.write("AscPrcValue", value);
  }

  void saveDescendingPriceValue(bool value) {
    storage.write("DescendingPrcValue", value);
  }

  void saveAscendingDistanceValue(bool value) {
    storage.write("AscDistValue", value);
  }

  void saveDescendingDistanceValue(bool value) {
    storage.write("DescendingDistValue", value);
  }

//----------------------------reading data -----------------------//
  getSliderValue() {
    return storage.read("sliderValue");
  }

  getAscendingPriceValue() {
    return storage.read("AscPrcValue");
  }

  getDescendingPriceValue() {
    return storage.read("DescendingPrcValue");
  }

  getAscendingDistanceValue() {
    return storage.read("AscDistValue");
  }

  getDescendingDistanceValue() {
    return storage.read("DescendingDistValue");
  }

//---------------------eraseAllData------------------------//
  void clearAllData() {
    storage.erase();
  }
}
