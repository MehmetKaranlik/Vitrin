import '../utils/TextUtils.dart';

class User {
  int id;
  String? name, email, avatarUrl;
  bool mobileVerified;
  String? mobile;
  bool blocked;

  User(this.id, this.name, this.email, this.avatarUrl, this.mobile,
      this.mobileVerified, this.blocked);

  static User fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());

    String? name = jsonObject['name'].toString();
    String? email = jsonObject['email'].toString();
    String? avatarUrl = jsonObject['avatar_url'].toString();
    String? mobile = jsonObject['mobile'].toString();
    bool mobileVerified = TextUtils.parseBool(jsonObject['mobile_verified']);
    bool blocked = TextUtils.parseBool(jsonObject['blocked']);

    return User(id, name, email, avatarUrl, mobile, mobileVerified, blocked);
  }

  static List<User> getListFromJson(List<dynamic> jsonArray) {
    List<User> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(User.fromJson(jsonArray[i]));
    }
    return list;
  }

  getAvatarUrl() {
    return TextUtils.getImageUrl(avatarUrl ?? "");
  }
}
