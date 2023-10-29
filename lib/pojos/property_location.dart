class PropertyLocation {
  double latitude;
  double longitude;
  String name;

  PropertyLocation({this.latitude, this.longitude, this.name});

  PropertyLocation.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['name'] = this.name;
    return data;
  }
}