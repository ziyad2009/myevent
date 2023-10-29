import 'package:myevents/pojos/upload.dart';

class VenueOptions {
  List<VenueTypes> venueTypes;

  VenueOptions({this.venueTypes});

  VenueOptions.fromJson(Map<String, dynamic> json) {
    if (json['venueTypes'] != null) {
      venueTypes = new List<VenueTypes>();
      json['venueTypes'].forEach((v) {
        venueTypes.add(new VenueTypes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.venueTypes != null) {
      data['venueTypes'] = this.venueTypes.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VenueTypes {
  String id;
  String typeName;
  UploadResponse typeIcon;

  VenueTypes({this.id, this.typeName, this.typeIcon});

  VenueTypes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    typeName = json['typeName'];
    if (json['typeIcon'] != null) {
      typeIcon = UploadResponse.fromJson(json['typeIcon']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['typeName'] = this.typeName;
    data['typeIcon'] = this.typeIcon.toJson();
    return data;
  }

  @override
  bool operator ==(other) {
    return other.id == id;
  }

  @override
  String toString() {
    return typeName;
  }
}
