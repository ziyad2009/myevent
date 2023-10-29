import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/pojos/my_venue_bookings.dart';
import 'package:transparent_image/transparent_image.dart';

import 'check_reserved_dates.dart';

class VenueRequestWidget extends StatelessWidget {
  final VenueBooking venueBooking;

  const VenueRequestWidget({Key key, this.venueBooking}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey[300])),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            child: FadeInImage.memoryNetwork(
                image:
                    venueBooking.property.featuredImage?.url ?? fallbackImage,
                placeholder: kTransparentImage,
                fit: BoxFit.cover,
                fadeInDuration: Duration(milliseconds: 250),
                height: 170,
                width: 100),
          ),
          Expanded(
            child: Container(
              padding:
                  EdgeInsets.only(right: 12, left: 11, top: 10, bottom: 8.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(venueBooking.property.title,
                            maxLines: 1,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18)),
                      ),
                      Mutation(
                          options: MutationOptions(
                              documentNode: gql(updateVenueBooking),
                              onError: (OperationException e) {
                                print(e.toString());
                              }),
                          builder:
                              (RunMutation runMutation, QueryResult result) {
                            return PopupMenuButton<BookingStats>(
                              child: _venueStatusContainer(),
                              onSelected: (BookingStats result) {
                                if (result == BookingStats.CONFIRM)
                                  runMutation({
                                    "field": {
                                      "where": {"id": venueBooking.id},
                                      "data": {"status": "confirmed"}
                                    }
                                  });
                                else if (result == BookingStats.CANCEL) {
                                  runMutation({
                                    "field": {
                                      "where": {"id": venueBooking.id},
                                      "data": {"status": "cancelled"}
                                    }
                                  });
                                } else if (result == BookingStats.SEE_DATES) {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => RequestReservedDates(
                                      targetQuery: getVenueBookingDates,
                                      targetID: venueBooking.id,
                                      targetType: "userAd",
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<BookingStats>>[
                                PopupMenuItem<BookingStats>(
                                  value: BookingStats.CONFIRM,
                                  child: Text('Confirm'),
                                ),
                                PopupMenuItem<BookingStats>(
                                  value: BookingStats.SEE_DATES,
                                  child: Text('Reserved Dates'),
                                ),
                                PopupMenuItem<BookingStats>(
                                  enabled:
                                      venueBooking.paymentStatus == "pending",
                                  value: BookingStats.CANCEL,
                                  child: Text('Cancel'),
                                ),
                              ],
                            );
                          })
                    ],
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.place,
                        color: Color(0x8A000000),
                        size: iconSize,
                      ),
                      SizedBox(width: 7),
                      Flexible(
                          child: Text(
                        venueBooking.property.address ?? "Address",
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: Color(0x8A000000),
                        size: iconSize,
                      ),
                      SizedBox(width: 7),
                      Flexible(
                          child: Text(
                        "${formattedTimeOnly(venueBooking.property.timeStart)} - ${formattedTimeOnly(venueBooking.property.timeEnd)}",
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.business,
                        color: Color(0x8A000000),
                        size: iconSize,
                      ),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          "${venueBooking.property.area / 1000} m²",
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.people,
                        color: Color(0x8A000000),
                        size: iconSize,
                      ),
                      SizedBox(width: 7),
                      Flexible(
                          child: Text(
                        "${venueBooking.property.accommodation}+",
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ))
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "SAR ${venueBooking.netPayment}",
                        style:
                            TextStyle(color: Colors.green[700], fontSize: 18),
                      ),
                      _paymentStatusTag()
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _venueStatusContainer() {
    if (venueBooking.status == "waiting")
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4), color: Colors.yellow[100]),
        padding: EdgeInsets.all(4),
        child: Text(
          "Waiting",
          style: TextStyle(
              color: Colors.yellow[600],
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      );
    else if (venueBooking.status == "confirmed")
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4), color: Colors.green[100]),
        padding: EdgeInsets.all(4),
        child: Text(
          "Confirmed",
          style: TextStyle(
              color: Colors.green, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      );
    else
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4), color: Colors.orange[100]),
        padding: EdgeInsets.all(4),
        child: Text(
          "Cancelled",
          style: TextStyle(
              color: Colors.orange, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      );
  }

  Widget _paymentStatusTag() {
    if (venueBooking.paymentStatus == "pending")
      return Text(
        "UNPAID",
        style: TextStyle(
          color: Colors.grey,
          letterSpacing: 1.24,
          fontSize: 18,
        ),
      );
    else if (venueBooking.paymentStatus == "submitted")
      return Text(
        "PAID",
        style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green[900],
            letterSpacing: 1.24,
            fontSize: 18),
      );
    else
      return Container();
  }
}
