class ReviewAverage {
  ReviewsConnection reviewsConnection;

  ReviewAverage({this.reviewsConnection});

  ReviewAverage.fromJson(Map<String, dynamic> json) {
    reviewsConnection = json['reviewsConnection'] != null
        ? new ReviewsConnection.fromJson(json['reviewsConnection'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.reviewsConnection != null) {
      data['reviewsConnection'] = this.reviewsConnection.toJson();
    }
    return data;
  }
}

class ReviewsConnection {
  Aggregate aggregate;

  ReviewsConnection({this.aggregate});

  ReviewsConnection.fromJson(Map<String, dynamic> json) {
    aggregate = json['aggregate'] != null
        ? new Aggregate.fromJson(json['aggregate'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.aggregate != null) {
      data['aggregate'] = this.aggregate.toJson();
    }
    return data;
  }
}

class Aggregate {
  Avg avg;
  int count;

  Aggregate({this.avg, this.count});

  Aggregate.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    avg = json['avg'] != null ? new Avg.fromJson(json['avg']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    if (this.avg != null) {
      data['avg'] = this.avg.toJson();
    }
    return data;
  }
}

class Avg {
  double stars;

  Avg({this.stars});

  Avg.fromJson(Map<String, dynamic> json) {
    /* When the rating is 5, server sends 5(which is int) so the value is casted toDouble() */
    stars = json['stars']?.toDouble() ?? 5.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stars'] = this.stars;
    return data;
  }
}
