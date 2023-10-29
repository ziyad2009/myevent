class SavedList {
  UserSaved user;

  SavedList({this.user});

  SavedList.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new UserSaved.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class UserSaved {
  List<SavedAds> savedAds;

  UserSaved({this.savedAds});

  UserSaved.fromJson(Map<String, dynamic> json) {
    if (json['savedAds'] != null) {
      savedAds = new List<SavedAds>();
      json['savedAds'].forEach((v) {
        savedAds.add(new SavedAds.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.savedAds != null) {
      data['savedAds'] = this.savedAds.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SavedAds {
  String id;

  SavedAds({this.id});

  SavedAds.fromJson(Map<String, dynamic> json) {
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
