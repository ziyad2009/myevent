import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/pages/booking_pages/booking_tab.dart';
import 'package:myevents/widgets/decorated_tabs.dart';

class MyBookingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: DecoratedTabBar(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0x2A7F0A3D),
                width: 2.0,
              ),
            ),
          ),
          tabBar: TabBar(indicatorColor: Color(0xFF720936), tabs: [
            Tab(
              child: Text(
                "SPACES",
                style: TextStyle(
                    color: exoticPurple, letterSpacing: 1.25, fontSize: 16.29),
              ),
            ),
            Tab(
              child: Text(
                "SERVICES",
                style: TextStyle(
                    color: exoticPurple, letterSpacing: 1.25, fontSize: 16.29),
              ),
            )
          ]),
        ),
        body: TabBarView(children: [
          BookingTab(
            myBookingQuery: fetchMyVenueBookings,
            bookingType: "userAd",
          ),
          BookingTab(
            myBookingQuery: fetchMyServiceBookings,
            bookingType: "service",
          )
        ]),
      ),
    );
  }
}
