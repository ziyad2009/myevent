class UserMe {
  Me me;

  UserMe({this.me});

  UserMe.fromJson(Map<String, dynamic> json) {
    me = json['me'] != null ? new Me.fromJson(json['me']) : null;
  }

  UserMe.initial()
      : me = Me(
            id: "", username: "", email: "", confirmed: false, blocked: false);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.me != null) {
      data['me'] = this.me.toJson();
    }
    return data;
  }
}

class Me {
  String id;
  String username;
  String email;
  bool confirmed;
  bool blocked;
  String firebaseID;

  Me({this.id, this.username, this.email, this.confirmed, this.blocked});

  Me.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    confirmed = json['confirmed'];
    blocked = json['blocked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['email'] = this.email;
    data['confirmed'] = this.confirmed;
    data['blocked'] = this.blocked;
    return data;
  }
}
