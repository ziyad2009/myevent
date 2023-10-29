import 'package:myevents/pojos/perk_list.dart';

class AllPerks {
  List<Perks> perks;

  AllPerks({this.perks});

  AllPerks.fromJson(Map<String, dynamic> json) {
    if (json['perks'] != null) {
      perks = new List<Perks>();
      json['perks'].forEach((v) {
        perks.add(new Perks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.perks != null) {
      data['perks'] = this.perks.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
