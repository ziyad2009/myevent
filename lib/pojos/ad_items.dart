import 'package:myevents/pojos/upload.dart';
import 'package:myevents/pojos/venue_options.dart';

class AdItems {
  List<UserAds> userAds;

  AdItems({this.userAds});

  AdItems.fromJson(Map<String, dynamic> json) {
    if (json['userAds'] != null) {
      userAds = new List<UserAds>();
      json['userAds'].forEach((v) {
        userAds.add(new UserAds.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userAds != null) {
      data['userAds'] = this.userAds.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserAds {
  String id;
  String title;
  String createdAt;
  int price;
  String description;
  String address;
  int accommodation;
  int area;
  String timeStart;
  String timeEnd;
  List<UploadResponse> adImages;
  UploadResponse featuredImage;
  String _isoAppend = "2012-12-12T";
  VenueOptions venueOptions;
  bool isSelected = false;
  bool isFeatured;
  String venueAddress;
  double latitude;
  double longitude;

  UserAds(
      {this.id,
      this.title,
      this.createdAt,
      this.price,
      this.description,
      this.address,
      this.accommodation,
      this.area,
      this.featuredImage,
      this.timeStart,
      this.venueOptions,
      this.latitude,
      this.longitude,
      this.venueAddress,
      this.timeEnd,
      this.isFeatured,
      this.adImages});

  String getTypesString() => venueOptions.venueTypes.join(',');

  UserAds.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    createdAt = json['createdAt'];
    price = json['price'];
    description = json['description'];
    address = json['address'];
    accommodation = json['accommodation'];
    isFeatured = json['isFeatured'];
    venueAddress = json['venueAddress'];
    latitude = json['venueLat'];
    longitude = json['venueLon'];
    area = json['area'];
    venueOptions =
        json['venueTypes'] != null ? new VenueOptions.fromJson(json) : null;
    timeStart = _isoAppend + json['timeStart'];
    timeEnd = _isoAppend + json['timeEnd'];
    if (json['featuredImage'] != null) {
      featuredImage = UploadResponse.fromJson(json['featuredImage']);
    }
    if (json['adImages'] != null) {
      adImages = new List<UploadResponse>();
      json['adImages'].forEach((v) {
        adImages.add(new UploadResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['createdAt'] = this.createdAt;
    data['price'] = this.price;
    data['description'] = this.description;
    data['address'] = this.address;
    data['accommodation'] = this.accommodation;
    data['area'] = this.area;
    data['timeStart'] = this.timeStart;
    data['timeEnd'] = this.timeEnd;
    if (this.adImages != null) {
      data['adImages'] = this.adImages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
