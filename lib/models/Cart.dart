
import 'package:vitrinint/models/Product.dart';
import 'package:vitrinint/models/ProductItem.dart';
import 'package:vitrinint/utils/TextUtils.dart';

class Cart {

  int id;
  bool active;
  int quantity;
  int productId;
  int productItemId;
  Product? product;
  ProductItem? productItem;

  Cart(this.id, this.active, this.quantity, this.productId, this.productItemId,
      this.product, this.productItem);

  static Cart fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    bool active = TextUtils.parseBool(jsonObject['active'].toString());
    int quantity = int.parse(jsonObject['quantity'].toString());
    int productId = int.parse(jsonObject['product_id'].toString());
    int productItemId = int.parse(jsonObject['product_item_id'].toString());
    Product? product;
    if (jsonObject['product'] != null) {
      product = Product.fromJson(jsonObject['product']);
      if (!active) {
        product.name = jsonObject['p_name'];
        product.description = jsonObject['p_description'];
        //TODO : product.price = double.parse(jsonObject['p_price'].toString());
        product.offer = int.parse(jsonObject['p_offer'].toString());
      }
    }
    ProductItem? productItem;
    if (jsonObject['product_item'] != null)
      productItem = ProductItem.fromJson(jsonObject['product_item']);

    return Cart(
        id, active, quantity, productId, productItemId, product, productItem);
  }

  static List<Cart> getListFromJson(List<dynamic> jsonArray) {
    List<Cart> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Cart.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'Cart{id: $id, active: $active, quantity: $quantity, productId: $productId, productItemId: $productItemId, product: $product, productItem: $productItem}';
  }


}