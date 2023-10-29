class SavedServicesList {
  _User user;

  SavedServicesList({this.user});

  SavedServicesList.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new _User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class _User {
  List<SavedServicesIDs> savedServices;

  _User({this.savedServices});

  _User.fromJson(Map<String, dynamic> json) {
    if (json['savedServices'] != null) {
      savedServices = new List<SavedServicesIDs>();
      json['savedServices'].forEach((v) {
        savedServices.add(new SavedServicesIDs.fromJson(v));
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

class SavedServicesIDs {
  String id;

  SavedServicesIDs({this.id});

  SavedServicesIDs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    return data;
  }

  @override
  bool operator ==(other) {
    return other.id == id;
  }
}
