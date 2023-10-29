import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/pojos/review_average.dart';
import 'package:myevents/pojos/service_items.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:transparent_image/transparent_image.dart';

class ServiceCard extends StatelessWidget {
  final Services service;
  ServiceCard({this.service});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: service.isSelected ? Color(0x2A7F0A3D) : Colors.transparent,
      ),
      width: 0.05,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: new BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              child: FadeInImage.memoryNetwork(
                fadeInDuration: Duration(milliseconds: 300),
                placeholder: kTransparentImage,
                image: service.serviceFeatureImage?.url ?? fallbackImage,
                fit: BoxFit.cover,
                height: 125,
                width: 177,
              ),
            ),
            Container(
              width: 177,
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          service.name ?? "Service Title",
                          maxLines: 1,
                          style:
                              TextStyle(color: Color(0xFF452B2D), fontSize: 16),
                        ),
                      ),
                      Visibility(
                        visible: service.isPremium,
                        child: Icon(
                          Icons.stars,
                          size: iconSize,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Query(
                      options: QueryOptions(
                          documentNode: gql(ratingAverage),
                          variables: {
                            "field": {"service": service.id}
                          }),
                      builder: (QueryResult result,
                          {VoidCallback refetch, FetchMore fetchMore}) {
                        if (result.hasException) {
                          return Text('Rating not available',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 10));
                        }

                        if (result.loading) {
                          return Text('Loading...',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 10));
                        }

                        ReviewAverage reviewAverage =
                            ReviewAverage.fromJson(result.data);

                        return SmoothStarRating(
                          starCount: 5,
                          borderColor: Color(0xFFDAA000),
                          color: Color(0xFFDAA000),
                          allowHalfRating: false,
                          rating: reviewAverage
                              .reviewsConnection.aggregate.avg.stars,
                          size: 9,
                        );
                      }),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    service.description ?? "Service Details",
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.place,
                              color: Color(0x8A000000),
                              size: iconSize,
                            ),
                            SizedBox(width: 7),
                            Flexible(
                                child: Text(
                              service.serviceAddress ?? "Address",
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ))
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.scatter_plot,
                              color: Color(0x8A000000),
                              size: iconSize,
                            ),
                            SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                "Perks ${service.perkList.perks.length}",
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Uploded On " + formattedDateTime(service.createdAt),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
