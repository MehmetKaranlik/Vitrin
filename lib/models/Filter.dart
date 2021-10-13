class Filter {
  late List<int> categories;
  late List<int> subCategories;
  late
  String name = "";
  late bool isInOffer;

  Filter() {
    categories = [];
    subCategories = [];
    isInOffer = false;
  }

  Filter.clear() {
    categories = [];
    isInOffer = false;
  }

  clearCategory(){
    this.categories = [];
  }

  toggleCategory(int categoryId) {
    if (categories.contains(categoryId)) {
      categories.remove(categoryId);
    } else {
      categories.add(categoryId);
    }
  }

  toggleSubCategory(int subCategoryId) {
    if (subCategories.contains(subCategoryId)) {
      subCategories.remove(subCategoryId);
    } else {
      subCategories.add(subCategoryId);
    }
  }

  setIsInOffer(bool isInOffer){
    this.isInOffer = isInOffer;
  }
}
