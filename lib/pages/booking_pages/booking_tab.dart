import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/pages/booking_pages/book_now_page.dart';
import 'package:myevents/pojos/my_service_bookings.dart';
import 'package:myevents/pojos/my_venue_bookings.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/widgets/check_reserved_dates.dart';
import 'package:myevents/widgets/service_booking_widget.dart';
import 'package:myevents/widgets/shimmer_effect.dart';
import 'package:myevents/widgets/venue_booking_widget.dart';
import 'package:myevents/graphql/query.dart';
import 'package:provider/provider.dart';

class BookingTab extends StatelessWidget {
  final String myBookingQuery;
  final String bookingType;
  const BookingTab({Key key, this.myBookingQuery, this.bookingType})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Query(
        options: QueryOptions(
            documentNode: gql(myBookingQuery),
            fetchPolicy: FetchPolicy.cacheAndNetwork,
            pollInterval: 20,
            variables: {
              "field": {"booker": Provider.of<UserBasic>(context).id}
            }),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.loading)
            return Center(
              child: LargeShimmmerTwo(),
            );
          else if (result.hasException)
            return Center(
              child: Text(
                "Sorry, something went wrong while fetching bookings!",
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
                    "You do not have any active venue bookings!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: exoticPurple, fontSize: 20),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: myVenueBookings.bookings.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      if (myVenueBookings.bookings.elementAt(index).status ==
                          "confirmed") {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => RequestReservedDates(
                            targetQuery: getVenueBookingDates,
                            targetID:
                                myVenueBookings.bookings.elementAt(index).id,
                            targetType: "userAd",
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookNowPage(
                                    targetType: "userAd",
                                    isEditingMode: true,
                                    editBookingID: myVenueBookings.bookings
                                        .elementAt(index)
                                        .id,
                                    targetID: myVenueBookings.bookings
                                        .elementAt(index)
                                        .property
                                        .id,
                                    targetName: myVenueBookings.bookings
                                        .elementAt(index)
                                        .property
                                        .title,
                                    perDayPrice: myVenueBookings.bookings
                                        .elementAt(index)
                                        .property
                                        .price,
                                  )));
                    },
                    child: VenueBookingWidget(
                      venueBooking: myVenueBookings.bookings.elementAt(index),
                    ),
                  ),
                );
              }
            } else {
              MyServiceBookings myServiceBookings =
                  MyServiceBookings.fromJson(result.data);
              if (myServiceBookings.bookings.isEmpty) {
                return Center(
                    child: Text(
                  "You do not have any active service bookings!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: exoticPurple, fontSize: 20),
                ));
              } else {
                return ListView.builder(
                  itemCount: myServiceBookings.bookings.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      if (myServiceBookings.bookings.elementAt(index).status ==
                          "confirmed") {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => RequestReservedDates(
                            targetQuery: getServiceBookingDates,
                            targetID:
                                myServiceBookings.bookings.elementAt(index).id,
                            targetType: "service",
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookNowPage(
                                    targetType: "service",
                                    isEditingMode: true,
                                    editBookingID: myServiceBookings.bookings
                                        .elementAt(index)
                                        .id,
                                    targetID: myServiceBookings.bookings
                                        .elementAt(index)
                                        .service
                                        .id,
                                    targetName: myServiceBookings.bookings
                                        .elementAt(index)
                                        .service
                                        .name,
                                    perDayPrice: myServiceBookings.bookings
                                        .elementAt(index)
                                        .service
                                        .pricePerDay,
                                  )));
                    },
                    child: ServiceBookingWidget(
                      serviceBooking:
                          myServiceBookings.bookings.elementAt(index),
                    ),
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
