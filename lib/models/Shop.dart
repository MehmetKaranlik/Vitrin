import '../utils/TextUtils.dart';

import 'Manager.dart';
import 'Product.dart';

class Shop {
  int? id, managerId;
  String name;
  String description;
  String email;
  String mobile;
  double latitude, longitude;
  String address;
  String imageUrl;
  int totalRating;
  double rating;
  double tax, deliveryRange;

  bool availableForDelivery;
  bool isOpen;
  int adminCommission;
  double minimumDeliveryCharge, deliveryCostMultiplier;
  Manager? manager;
  List<Product> products;

  Shop(
      this.id,
      this.managerId,
      this.name,
      this.description,
      this.email,
      this.mobile,
      this.latitude,
      this.longitude,
      this.address,
      this.imageUrl,
      this.totalRating,
      this.rating,
      this.tax,
      this.deliveryRange,
      this.availableForDelivery,
      this.isOpen,
      this.adminCommission,
      this.minimumDeliveryCharge,
      this.deliveryCostMultiplier,
      this.manager,
      this.products);

  static fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    String name = jsonObject['name'].toString();
    String description = jsonObject['description'].toString();
    String email = jsonObject['email'].toString();
    String mobile = jsonObject['mobile'].toString();
    double latitude = double.parse(jsonObject['latitude'].toString());
    double longitude = double.parse(jsonObject['longitude'].toString());
    String address = jsonObject['address'].toString();
    String imageUrl = TextUtils.getImageUrl(jsonObject['image_url'].toString());

    int totalRating = int.parse(jsonObject['total_rating'].toString());
    double rating = double.parse(jsonObject['rating'].toString());

    double tax = double.parse(jsonObject['default_tax'].toString());
    double deliveryRange =
        double.parse(jsonObject['delivery_range'].toString());
    bool availableForDelivery =
        TextUtils.parseBool(jsonObject['available_for_delivery'].toString());
    bool isOpen = TextUtils.parseBool(jsonObject['open']);
    int adminCommission = int.parse(jsonObject['admin_commission'].toString());
    double minimumDeliveryCharge =
        double.parse(jsonObject['minimum_delivery_charge'].toString());
    double deliveryCostMultiplier =
        double.parse(jsonObject['delivery_cost_multiplier'].toString());

    int? managerId;
    if (jsonObject['manager_id'] != null)
      managerId = int.parse(jsonObject['manager_id'].toString());

    Manager? manager;
    if (jsonObject['manager'] != null)
      manager = Manager.fromJson(jsonObject['manager']);

    List<Product> products = [];
    if (jsonObject['products'] != null)
      products = Product.getListFromJson(jsonObject['products']);

    return Shop(
        id,
        managerId,
        name,
        description,
        email,
        mobile,
        latitude,
        longitude,
        address,
        imageUrl,
        totalRating,
        rating,
        tax,
        deliveryRange,
        availableForDelivery,
        isOpen,
        adminCommission,
        minimumDeliveryCharge,
        deliveryCostMultiplier,
        manager,
        products);
  }

  static List<Shop> getListFromJson(List<dynamic> jsonArray) {
    List<Shop> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Shop.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'Shop{id: $id, managerId: $managerId, name: $name, description: $description, email: $email, mobile: $mobile, latitude: $latitude, longitude: $longitude, address: $address, imageUrl: $imageUrl, totalRating: $totalRating, rating: $rating, tax: $tax, deliveryRange: $deliveryRange, availableForDelivery: $availableForDelivery, isOpen: $isOpen, adminCommission: $adminCommission, minimumDeliveryCharge: $minimumDeliveryCharge, deliveryCostMultiplier: $deliveryCostMultiplier, manager: $manager, products: $products}';
  }

  static String getPlaceholderImage() {
    return './assets/images/placeholder/no-shop-image.png';
  }
}
