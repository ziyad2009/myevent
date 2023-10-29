import 'package:myevents/pojos/offline_dates.dart';
import 'package:myevents/pojos/user_basic.dart';

class ServiceBookingDates {
  ServiceBooking serviceBooking;

  ServiceBookingDates({this.serviceBooking});

  ServiceBookingDates.fromJson(Map<String, dynamic> json) {
    serviceBooking = json['serviceBooking'] != null
        ? new ServiceBooking.fromJson(json['serviceBooking'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.serviceBooking != null) {
      data['serviceBooking'] = this.serviceBooking.toJson();
    }
    return data;
  }
}

class ServiceBooking {
  List<OfflineDates> bookedDates;
  UserBasic booker;

  ServiceBooking({this.bookedDates});

  ServiceBooking.fromJson(Map<String, dynamic> json) {
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
