import 'package:myevents/pojos/perk_list.dart';
import 'package:myevents/pojos/upload.dart';

class ServiceItems {
  List<Services> services;

  ServiceItems({this.services});

  ServiceItems.fromJson(Map<String, dynamic> json) {
    if (json['services'] != null) {
      services = new List<Services>();
      json['services'].forEach((v) {
        services.add(new Services.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.services != null) {
      data['services'] = this.services.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Services {
  String id;
  String name;
  String createdAt;
  String serviceAddress;
  UploadResponse serviceFeatureImage;
  int pricePerDay;
  bool isPremium;
  String description;
  PerkList perkList;
  bool isSelected = false;

  Services(
      {this.id,
      this.name,
      this.createdAt,
      this.serviceAddress,
      this.serviceFeatureImage,
      this.pricePerDay,
      this.isPremium,
      this.description,
      this.perkList});

  Services.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    createdAt = json['createdAt'];
    serviceAddress = json['serviceAddress'];
    serviceFeatureImage = json['serviceFeatureImage'] != null
        ? new UploadResponse.fromJson(json['serviceFeatureImage'])
        : null;
    pricePerDay = json['pricePerDay'];
    isPremium = json['isPremium'];
    description = json['description'];
    if (json['perkList'] != null) {
      perkList = PerkList.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['createdAt'] = this.createdAt;
    data['serviceAddress'] = this.serviceAddress;
    if (this.serviceFeatureImage != null) {
      data['serviceFeatureImage'] = this.serviceFeatureImage.toJson();
    }
    data['pricePerDay'] = this.pricePerDay;
    data['isPremium'] = this.isPremium;
    data['description'] = this.description;
    return data;
  }
}
