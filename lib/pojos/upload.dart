class UploadResponse {
  String sId;
  String url = "https://admin.munasaba.co";

  UploadResponse({this.sId, this.url});

  UploadResponse.fromJson(Map<String, dynamic> json) {
    sId = json['id'];
    url = url + json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.sId;
    data['url'] = this.url;
    return data;
  }
}
