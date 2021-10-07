import 'Category.dart';

class SubCategory {
  int id, categoryId;
  String title;
  String? description;

  Category? category;

  SubCategory(
      this.id, this.categoryId, this.title, this.description, this.category);

  static fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int categoryId = int.parse(jsonObject['category_id'].toString());
    String title = jsonObject['title'].toString();

    String? description;
    if (jsonObject['description'] != null)
      description = jsonObject['description'].toString();

    Category? category;
    if (jsonObject['category'] != null) {
      category = Category.fromJson(jsonObject['category']);
    }
    return SubCategory(id, categoryId, title, description, category);
  }

  static List<SubCategory> getListFromJson(List<dynamic> jsonArray) {
    List<SubCategory> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(SubCategory.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'SubCategory{id: $id, categoryId: $categoryId, title: $title, description: $description, category: $category}';
  }
}
