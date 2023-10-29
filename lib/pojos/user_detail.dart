import 'package:myevents/pojos/upload.dart';

class UserDetail {
  User user;

  UserDetail({this.user});

  UserDetail.fromJson(Map<String, dynamic> json) {
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
  String id;
  String sTypename;
  String username;
  String email;
  String fullName;
  String phone;
  String firebaseID;
  String shortBio;
  String aboutDescription;
  String facebookLink;
  String websiteLink;
  UploadResponse profilePicture;
  UploadResponse coverImage;
  List<UploadResponse> aboutImages;

  User(
      {this.id,
      this.sTypename,
      this.username,
      this.email,
      this.fullName,
      this.phone,
      this.shortBio,
      this.firebaseID,
      this.aboutDescription,
      this.facebookLink,
      this.websiteLink,
      this.profilePicture,
      this.coverImage,
      this.aboutImages});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sTypename = json['__typename'];
    username = json['username'];
    email = json['email'];
    fullName = json['fullName'];
    phone = json['phone'];
    shortBio = json['shortBio'];
    aboutDescription = json['aboutDescription'];
    facebookLink = json['facebookLink'];
    websiteLink = json['websiteLink'];
    firebaseID = json['firebaseID'];
    profilePicture = json['profilePicture'] != null
        ? new UploadResponse.fromJson(json['profilePicture'])
        : null;
    coverImage = json['coverImage'] != null
        ? new UploadResponse.fromJson(json['coverImage'])
        : null;
    if (json['aboutImages'] != null) {
      aboutImages = new List<UploadResponse>();
      json['aboutImages'].forEach((v) {
        aboutImages.add(new UploadResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['__typename'] = this.sTypename;
    data['username'] = this.username;
    data['email'] = this.email;
    data['fullName'] = this.fullName;
    data['phone'] = this.phone;
    data['shortBio'] = this.shortBio;
    data['aboutDescription'] = this.aboutDescription;
    data['facebookLink'] = this.facebookLink;
    data['websiteLink'] = this.websiteLink;
    if (this.profilePicture != null) {
      data['profilePicture'] = this.profilePicture.toJson();
    }
    if (this.coverImage != null) {
      data['coverImage'] = this.coverImage.toJson();
    }
    if (this.aboutImages != null) {
      data['aboutImages'] = this.aboutImages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
