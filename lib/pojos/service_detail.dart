import 'package:myevents/pojos/offline_dates.dart';
import 'package:myevents/pojos/perk_list.dart';
import 'package:myevents/pojos/upload.dart';
import 'package:myevents/pojos/user_detail.dart';

class ServiceDetail {
  Service service;

  ServiceDetail({this.service});

  ServiceDetail.fromJson(Map<String, dynamic> json) {
    service =
        json['service'] != null ? new Service.fromJson(json['service']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.service != null) {
      data['service'] = this.service.toJson();
    }
    return data;
  }
}

class Service {
  String id;
  String name;
  String description;
  String createdAt;
  String updatedAt;
  String serviceAddress;
  double latitude;
  double longitude;
  int pricePerDay;
  PerkList perkList;
  String adStatus;
  bool isPremium;
  User provider;
  List<UploadResponse> servicePhotos;
  UploadResponse serviceFeatureImage;
  UploadResponse serviceVideo;
  List<OfflineDates> offlineDates;

  Service(
      {this.id,
      this.name,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.serviceAddress,
      this.latitude,
      this.longitude,
      this.pricePerDay,
      this.adStatus,
      this.perkList,
      this.isPremium,
      this.provider,
      this.servicePhotos,
      this.serviceFeatureImage,
      this.serviceVideo});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    name = json['name'];
    description = json['description'];
    adStatus = json['adStatus'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    serviceAddress = json['serviceAddress'];
    latitude = json['serviceLat']?.toDouble() ?? 0.0;
    longitude = json['serviceLon']?.toDouble() ?? 0.0;
    pricePerDay = json['pricePerDay'];
    if (json['perkList'] != null) {
      perkList = PerkList.fromJson(json);
    }
    isPremium = json['isPremium'];
    provider =
        json['provider'] != null ? new User.fromJson(json['provider']) : null;
    if (json['servicePhotos'] != null) {
      servicePhotos = new List<UploadResponse>();
      json['servicePhotos'].forEach((v) {
        servicePhotos.add(new UploadResponse.fromJson(v));
      });
    }
    serviceFeatureImage = json['serviceFeatureImage'] != null
        ? new UploadResponse.fromJson(json['serviceFeatureImage'])
        : null;
    if (json['serviceVideo'] != null) {
      serviceVideo = UploadResponse.fromJson(json['serviceVideo']);
    }
    if (json['unavailableDates'] != null) {
      offlineDates = new List<OfflineDates>();
      json['unavailableDates'].forEach((v) {
        offlineDates.add(new OfflineDates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;

    data['name'] = this.name;
    data['description'] = this.description;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    // if (this.serviceLocation != null) {
    //   data['serviceLocation'] =
    //       this.serviceLocation.map((v) => v.toJson()).toList();
    // }
    data['pricePerDay'] = this.pricePerDay;

    data['isPremium'] = this.isPremium;
    if (this.provider != null) {
      data['provider'] = this.provider.toJson();
    }
    if (this.servicePhotos != null) {
      data['servicePhotos'] =
          this.servicePhotos.map((v) => v.toJson()).toList();
    }
    if (this.serviceFeatureImage != null) {
      data['serviceFeatureImage'] = this.serviceFeatureImage.toJson();
    }
    data['serviceVideo'] = this.serviceVideo;
    return data;
  }
}
