import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/pojos/review_list.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ReviewCard extends StatelessWidget {
  final Reviews review;
  ReviewCard({this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        color: Color(0xFFFAFAFA),
        height: 150,
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: review.reviewer.profilePicture != null
                    ? NetworkImage(
                        review.reviewer.profilePicture.url,
                      )
                    : AssetImage("lib/assets/crying.png"),
              ),
              title: Text(
                review.reviewer.fullName ?? "MyEvents User",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF646464)),
              ),
              subtitle: SmoothStarRating(
                starCount: 5,
                borderColor: Color(0xFFDAA000),
                color: Color(0xFFDAA000),
                allowHalfRating: false,
                rating: review.stars.toDouble() ?? 0.0,
                size: 12,
              ),
            ),
            Text(review.content ?? "", maxLines: 5),
          ],
        ),
      ),
    );
  }
}
