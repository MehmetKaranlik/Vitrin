import 'ProductItemFeature.dart';

class ProductItem {
  int id;
  int price, revenue, quantity;
  List<ProductItemFeature> productItemFeatures;

  ProductItem(this.id, this.price, this.revenue, this.quantity,
      this.productItemFeatures);

  static ProductItem fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int price = int.parse(jsonObject['price'].toString());
    int revenue = int.parse(jsonObject['revenue'].toString());
    int quantity = int.parse(jsonObject['quantity'].toString());
    List<ProductItemFeature> productItemFeatures =
        ProductItemFeature.getListFromJson(jsonObject['product_item_features']);
    return ProductItem(id, price, revenue, quantity, productItemFeatures);
  }

  static List<ProductItem> getListFromJson(List<dynamic> jsonArray) {
    List<ProductItem> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(ProductItem.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'ProductItem{id: $id, price: $price, revenue: $revenue, quantity: $quantity, productItemFeatures: $productItemFeatures}';
  }
}
