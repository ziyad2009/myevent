import 'package:myevents/pojos/offline_dates.dart';
import 'package:myevents/pojos/perk_list.dart';
import 'package:myevents/pojos/upload.dart';
import 'package:myevents/pojos/user_detail.dart';
import 'package:myevents/pojos/venuE_options.dart';

class AdDetail {
  UserAd userAd;

  AdDetail({this.userAd});

  AdDetail.fromJson(Map<String, dynamic> json) {
    userAd =
        json['userAd'] != null ? new UserAd.fromJson(json['userAd']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userAd != null) {
      data['userAd'] = this.userAd.toJson();
    }
    return data;
  }
}

class UserAd {
  String id;
  String title;
  String createdAt;
  String adStatus;
  User seller;
  int price;
  String description;
  String venueAddress;
  double latitude;
  double longitude;
  String category;
  int accommodation;
  int area;
  String sellerDesignation;
  String availableTill;
  String timeStart;
  String timeEnd;
  PerkList perkList;
  bool isFeatured;
  List<UploadResponse> adImages;
  UploadResponse propertyVideo;
  VenueOptions venueOptions;
  List<OfflineDates> offlineDates;
  final String _isoAppend = "2012-12-12T";

  UserAd(
      {this.id,
      this.title,
      this.createdAt,
      this.seller,
      this.price,
      this.description,
      this.adStatus,
      this.sellerDesignation,
      this.venueAddress,
      this.latitude,
      this.longitude,
      this.category,
      this.accommodation,
      this.venueOptions,
      this.area,
      this.availableTill,
      this.timeStart,
      this.timeEnd,
      this.perkList,
      this.isFeatured,
      this.offlineDates,
      this.adImages});

  UserAd.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    createdAt = json['createdAt'];
    seller = json['seller'] != null ? new User.fromJson(json['seller']) : null;
    price = json['price'];
    description = json['description'];
    venueAddress = json['venueAddress'];
    latitude = json['venueLat']?.toDouble() ?? 0.0;
    longitude = json['venueLon']?.toDouble() ?? 0.0;
    adStatus = json['adStatus'];
    venueOptions =
        json['venueTypes'] != null ? new VenueOptions.fromJson(json) : null;
    accommodation = json['accommodation'];
    area = json['area'];
    availableTill = json['availableTill'];
    timeStart = _isoAppend + json['timeStart'];
    timeEnd = _isoAppend + json['timeEnd'];
    sellerDesignation = json['sellerDesignation'];
    isFeatured = json['isFeatured'];
    if (json['unavailableDates'] != null) {
      offlineDates = new List<OfflineDates>();
      json['unavailableDates'].forEach((v) {
        offlineDates.add(new OfflineDates.fromJson(v));
      });
    }
    if (json['perkList'] != null) {
      perkList = PerkList.fromJson(json);
    }
    if (json['propertyVideo'] != null) {
      propertyVideo = UploadResponse.fromJson(json['propertyVideo']);
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
    if (this.seller != null) {
      data['seller'] = this.seller.toJson();
    }
    data['price'] = this.price;
    data['description'] = this.description;

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
