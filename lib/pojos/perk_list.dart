class PerkList {
  List<Perks> perks;

  PerkList({this.perks});

  PerkList.fromJson(Map<String, dynamic> json) {
    if (json['perkList'] != null) {
      perks = new List<Perks>();
      json['perkList'].forEach((v) {
        perks.add(new Perks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.perks != null) {
      data['perkList'] = this.perks.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Perks {
  String id;
  String perkName;

  Perks({this.id, this.perkName});

  Perks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    perkName = json['perkName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['perkName'] = this.perkName;
    return data;
  }

  @override
  bool operator ==(other) {
    return other.id == id;
  }
}
