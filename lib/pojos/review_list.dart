import 'package:myevents/pojos/user_basic.dart';

class ReviewList {
  List<Reviews> reviews;

  ReviewList({this.reviews});

  ReviewList.fromJson(Map<String, dynamic> json) {
    if (json['reviews'] != null) {
      reviews = new List<Reviews>();
      json['reviews'].forEach((v) {
        reviews.add(new Reviews.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.reviews != null) {
      data['reviews'] = this.reviews.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Reviews {
  String id;
  String content;
  int stars;
  UserBasic reviewer;

  Reviews({this.id, this.content, this.stars, this.reviewer});

  Reviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['content'];
    stars = json['stars'];
    reviewer = json['reviewer'] != null
        ? new UserBasic.fromJson(json['reviewer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['content'] = this.content;
    data['stars'] = this.stars;
    if (this.reviewer != null) {
      data['reviewer'] = this.reviewer.toJson();
    }
    return data;
  }
}
