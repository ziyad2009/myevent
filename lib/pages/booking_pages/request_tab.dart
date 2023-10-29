import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/pojos/my_service_bookings.dart';
import 'package:myevents/pojos/my_venue_bookings.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/widgets/service_request_widget.dart';
import 'package:myevents/widgets/shimmer_effect.dart';
import 'package:myevents/widgets/venue_request_widget.dart';
import 'package:provider/provider.dart';

class RequestTab extends StatelessWidget {
  final String myBookingQuery;
  final String bookingType;
  const RequestTab({Key key, this.myBookingQuery, this.bookingType})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Query(
        options: QueryOptions(
            fetchPolicy: FetchPolicy.cacheAndNetwork,
            pollInterval: 4,
            documentNode: gql(myBookingQuery),
            variables: {
              "field": {
                bookingType == "userAd" ? "property" : "service": {
                  bookingType == "userAd" ? "seller" : "provider":
                      Provider.of<UserBasic>(context).id
                }
              }
            }),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.loading)
            return LargeShimmmerTwo();
          else if (result.hasException)
            return Center(
              child: Text(
                "Sorry, something went wrong while fetching requests!",
                textAlign: TextAlign.center,
                style: TextStyle(color: exoticPurple),
              ),
            );
          else {
            if (bookingType == "userAd") {
              MyVenueBookings myVenueBookings =
                  MyVenueBookings.fromJson(result.data);

              if (myVenueBookings.bookings.isEmpty) {
                return Center(
                  child: Text(
                    "You do not have any active venue requests!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: exoticPurple, fontSize: 20),
                  ),
                );
              } else {
                return ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                  itemCount: myVenueBookings.bookings.length,
                  itemBuilder: (context, index) => VenueRequestWidget(
                    venueBooking: myVenueBookings.bookings.elementAt(index),
                  ),
                );
              }
            } else {
              MyServiceBookings myServiceBookings =
                  MyServiceBookings.fromJson(result.data);
              if (myServiceBookings.bookings.isEmpty) {
                return Center(
                    child: Text(
                  "You do not have any active service requests!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: exoticPurple, fontSize: 20),
                ));
              } else {
                return ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                  itemCount: myServiceBookings.bookings.length,
                  itemBuilder: (context, index) => ServiceRequestWidget(
                    serviceBooking: myServiceBookings.bookings.elementAt(index),
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }
}
