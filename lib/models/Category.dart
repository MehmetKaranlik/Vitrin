import '../utils/TextUtils.dart';

import 'SubCategory.dart';

class Category {
  int id;
  String title;
  String description;
  String imageUrl;
  List<SubCategory>? subCategories;

  Category(
      this.id, this.title, this.description, this.imageUrl, this.subCategories);

  static fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    String title = jsonObject['title'].toString();
    String description = jsonObject['description'].toString();
    String imageUrl = TextUtils.getImageUrl(jsonObject['image_url'].toString());

    List<SubCategory>? subCategories;
    if (jsonObject['sub_categories'] != null) {
      subCategories = SubCategory.getListFromJson(jsonObject['sub_categories']);
    }

    return Category(id, title, description, imageUrl, subCategories);
  }

  static List<Category> getListFromJson(List<dynamic> jsonArray) {
    List<Category> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Category.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'Category{id: $id, title: $title, description: $description, imageUrl: $imageUrl}';
  }
}
