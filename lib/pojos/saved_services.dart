import 'package:myevents/pojos/service_items.dart';

class SavedServices {
  User user;

  SavedServices({this.user});

  SavedServices.fromJson(Map<String, dynamic> json) {
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
  List<Services> savedServices;

  User({this.savedServices});

  User.fromJson(Map<String, dynamic> json) {
    if (json['savedServices'] != null) {
      savedServices = new List<Services>();
      json['savedServices'].forEach((v) {
        savedServices.add(new Services.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.savedServices != null) {
      data['savedServices'] =
          this.savedServices.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
