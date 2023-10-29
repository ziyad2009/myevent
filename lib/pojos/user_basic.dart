import 'package:myevents/pojos/upload.dart';

class UserSearchList {
  List<UserBasic> users;

  UserSearchList({this.users});

  UserSearchList.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = new List<UserBasic>();
      json['users'].forEach((v) {
        users.add(new UserBasic.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.users != null) {
      data['users'] = this.users.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserBasic {
  String id;
  String fullName;
  String phone;
  String username;
  bool confirmed;
  bool blocked;
  String firebaseID;
  UploadResponse profilePicture;

  UserBasic.initial()
      : id = "",
        fullName = "notlogged",
        username = "none",
        profilePicture = null,
        firebaseID = null,
        confirmed = false,
        blocked = false;

  UserBasic(
      {this.id,
      this.fullName,
      this.username,
      this.confirmed,
      this.blocked,
      this.firebaseID,
      this.profilePicture});

  UserBasic.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    username = json['username'];
    confirmed = json['confirmed'];
    blocked = json['blocked'];
    phone = json['phone'];
    firebaseID = json['firebaseID'];
    profilePicture = json['profilePicture'] != null
        ? new UploadResponse.fromJson(json['profilePicture'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fullName'] = this.fullName;
    data['username'] = this.username;
    data['confirmed'] = this.confirmed;
    data['blocked'] = this.blocked;
    data['firebaseID'] = this.firebaseID;
    if (this.profilePicture != null) {
      data['profilePicture'] = this.profilePicture.toJson();
    }
    return data;
  }
}
