import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/pojos/service_booking_dates.dart';
import 'package:myevents/pojos/venue_booking_dates.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestReservedDates extends StatelessWidget {
  final String targetQuery;
  final String targetID;
  final String targetType;

  const RequestReservedDates(
      {Key key, this.targetQuery, this.targetID, this.targetType})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        documentNode: gql(targetQuery),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        variables: {"field": targetID},
      ),
      builder: (QueryResult result,
          {VoidCallback refetch, FetchMore fetchMore}) {
        if (result.loading)
          return Center(child: CircularProgressIndicator());
        else if (result.hasException) {
          return Center(
            child: Text(
              "Sorry, something went wrong while loading the reserved dates",
              style: TextStyle(color: Colors.grey),
            ),
          );
        } else {
          if (targetType == "userAd") {
            VenueBookingDates venueBookingDates =
                VenueBookingDates.fromJson(result.data);
            return Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      venueBookingDates.booking.booker.profilePicture?.url ??
                          fallbackImage,
                    ),
                  ),
                  title: Text(
                    "Booking By ${venueBookingDates.booking.booker.fullName}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text("Tap on the phone icon to talk",
                      style: TextStyle(color: Colors.grey)),
                  trailing: IconButton(
                      icon: Icon(Icons.call, color: exoticPurple),
                      onPressed: () async {
                        if (venueBookingDates.booking.booker.phone == null) {
                          BotToast.showText(
                              text: "Contact number is not available");
                          return;
                        }
                        String url =
                            "tel:+966" + venueBookingDates.booking.booker.phone;

                        // If dailer is not available, catch the error and show show the toast message
                        try {
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        } catch (e) {
                          BotToast.showText(
                              text: "Contact number is not available");
                        }
                      }),
                ),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: venueBookingDates.booking.bookedDates.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(children: [
                        Container(height: 5, width: 10, color: exoticPurple),
                        SizedBox(width: 10),
                        Text(
                          venueBookingDates.booking.bookedDates
                              .elementAt(index)
                              .toString(),
                          style: TextStyle(color: exoticPurple, fontSize: 16),
                        )
                      ]),
                    ),
                  ),
                ),
              ],
            );
          } else {
            ServiceBookingDates serviceBookingDates =
                ServiceBookingDates.fromJson(result.data);
            return Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      serviceBookingDates
                              .serviceBooking.booker.profilePicture?.url ??
                          fallbackImage,
                    ),
                  ),
                  title: Text(
                    "Booking By ${serviceBookingDates.serviceBooking.booker.fullName}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text("Tap on the phone icon to talk",
                      style: TextStyle(color: Colors.grey)),
                  trailing: IconButton(
                    icon: Icon(Icons.call, color: exoticPurple),
                    onPressed: () async {
                      if (serviceBookingDates.serviceBooking.booker.phone ==
                          null) {
                        BotToast.showText(
                            text: "Contact number is not available");
                        return;
                      }
                      String url = "tel:+966" +
                          serviceBookingDates.serviceBooking.booker.phone;

                      // If dailer is not available, catch the error and show show the toast message
                      try {
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      } catch (e) {
                        BotToast.showText(
                            text: "Contact number is not available");
                      }
                    },
                  ),
                ),
                Divider(thickness: 1),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount:
                        serviceBookingDates.serviceBooking.bookedDates.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(children: [
                        Container(height: 5, width: 10, color: exoticPurple),
                        SizedBox(width: 10),
                        Text(
                          serviceBookingDates.serviceBooking.bookedDates
                              .elementAt(index)
                              .toString(),
                          style: TextStyle(color: exoticPurple, fontSize: 16),
                        )
                      ]),
                    ),
                  ),
                ),
              ],
            );
          }
        }
      },
    );
  }
}
