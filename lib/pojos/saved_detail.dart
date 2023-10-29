import 'package:myevents/pojos/ad_items.dart';

class SavedDetail {
  User user;

  SavedDetail({this.user});

  SavedDetail.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class User {
  List<UserAds> savedAds;

  User({this.savedAds});

  User.fromJson(Map<String, dynamic> json) {
    if (json['savedAds'] != null) {
      savedAds = new List<UserAds>();
      json['savedAds'].forEach((v) {
        savedAds.add(new UserAds.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.savedAds != null) {
      data['savedAds'] = this.savedAds.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
