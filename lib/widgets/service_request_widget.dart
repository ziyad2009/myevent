import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/pojos/my_service_bookings.dart';
import 'package:myevents/widgets/check_reserved_dates.dart';
import 'package:transparent_image/transparent_image.dart';

class ServiceRequestWidget extends StatelessWidget {
  final ServiceBooking serviceBooking;

  const ServiceRequestWidget({Key key, this.serviceBooking}) : super(key: key);
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
                image: serviceBooking.service.serviceFeatureImage.url ??
                    fallbackImage,
                placeholder: kTransparentImage,
                fit: BoxFit.cover,
                fadeInDuration: Duration(milliseconds: 250),
                height: 140,
                width: 100),
          ),
          Expanded(
            child: Container(
              padding:
                  EdgeInsets.only(right: 12, left: 11, top: 10, bottom: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(serviceBooking.service.name,
                            maxLines: 1,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18)),
                      ),
                      Mutation(
                          options: MutationOptions(
                              documentNode: gql(updateServiceBooking)),
                          builder:
                              (RunMutation runMutation, QueryResult result) {
                            return PopupMenuButton<BookingStats>(
                              child: _serviceStatusContainer(),
                              onSelected: (BookingStats result) {
                                if (result == BookingStats.CONFIRM)
                                  runMutation({
                                    "field": {
                                      "where": {"id": serviceBooking.id},
                                      "data": {"status": "confirmed"}
                                    }
                                  });
                                else if (result == BookingStats.CANCEL)
                                  runMutation({
                                    "field": {
                                      "where": {"id": serviceBooking.id},
                                      "data": {"status": "cancelled"}
                                    }
                                  });
                                else if (result == BookingStats.SEE_DATES) {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => RequestReservedDates(
                                      targetQuery: getServiceBookingDates,
                                      targetID: serviceBooking.id,
                                      targetType: "service",
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
                                      serviceBooking.paymentStatus == "pending",
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
                        serviceBooking.service.serviceAddress ?? "Address",
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.scatter_plot,
                        color: Color(0x8A000000),
                        size: iconSize,
                      ),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          "${serviceBooking.service.perkList.perks.length}+ Perks",
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "SAR ${serviceBooking.netPayment}",
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

  Widget _serviceStatusContainer() {
    if (serviceBooking.status == "waiting")
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
    else if (serviceBooking.status == "confirmed")
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
    if (serviceBooking.paymentStatus == "pending")
      return Text(
        "UNPAID",
        style: TextStyle(
          color: Colors.grey,
          letterSpacing: 1.24,
          fontSize: 18,
        ),
      );
    else if (serviceBooking.paymentStatus == "submitted")
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
