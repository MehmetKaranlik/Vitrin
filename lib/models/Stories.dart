import '../utils/TextUtils.dart';

class Stories {
  int id;
  int shopId;
  String storyImage;
  String createdAt;
  String updatedAt;
  String shopImage;

  Stories(this.id, this.shopId, this.storyImage, this.createdAt, this.updatedAt,
      this.shopImage);

  static fromJson(Map<String, dynamic> jsonObject) {
    String shopImage =
        TextUtils.getImageUrl(jsonObject["image_url"].toString());
    int id = int.parse(jsonObject['id'].toString());
    int shopId = int.parse(jsonObject['shop_id'].toString());
    String storyImage =
        TextUtils.getImageUrl(jsonObject['story_image'].toString());
    String createdAt = jsonObject['created_at'].toString();
    String updatedAt = jsonObject['updated_at'].toString();

    return Stories(id, shopId, storyImage, createdAt, updatedAt, shopImage);
  }

  static List<Stories> getListFromJson(List<dynamic> jsonArray) {
    List<Stories> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Stories.fromJson(jsonArray[i]));
    }
    // print(jsonArray);
    print(list.length);
    return list;
  }

  @override
  String toString() {
    return 'Shop{id: $id, shopId: $shopId, storyImage: $storyImage, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  static String getPlaceholderImage() {
    return './assets/images/placeholder/no-shop-image.png';
  }
}
