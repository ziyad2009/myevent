import 'package:myevents/pojos/offline_dates.dart';
import 'package:myevents/pojos/user_basic.dart';

class VenueBookingDates {
  Booking booking;

  VenueBookingDates({this.booking});

  VenueBookingDates.fromJson(Map<String, dynamic> json) {
    booking =
        json['booking'] != null ? new Booking.fromJson(json['booking']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.booking != null) {
      data['booking'] = this.booking.toJson();
    }
    return data;
  }
}

class Booking {
  List<OfflineDates> bookedDates;
  UserBasic booker;

  Booking({this.bookedDates});

  Booking.fromJson(Map<String, dynamic> json) {
    if (json['bookedDates'] != null) {
      bookedDates = new List<OfflineDates>();
      json['bookedDates'].forEach((v) {
        bookedDates.add(new OfflineDates.fromJson(v));
      });
    }
    if (json['booker'] != null) {
      booker = UserBasic.fromJson(json['booker']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.bookedDates != null) {
      data['bookedDates'] = this.bookedDates.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
