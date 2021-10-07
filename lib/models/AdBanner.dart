class AdBanner {
  int id;
  String url;

  AdBanner(this.id, this.url);

  static AdBanner fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    String url = jsonObject['url'].toString();

    return AdBanner(id, url);
  }

  static List<AdBanner> getListFromJson(List<dynamic> jsonArray) {
    List<AdBanner> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(AdBanner.fromJson(jsonArray[i]));
    }
    return list;
  }
}
