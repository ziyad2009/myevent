import 'package:myevents/pojos/ad_items.dart';
import 'package:myevents/pojos/booking_class.dart';

class MyVenueBookings {
  List<VenueBooking> bookings;

  MyVenueBookings({this.bookings});

  MyVenueBookings.fromJson(Map<String, dynamic> json) {
    if (json['bookings'] != null) {
      bookings = new List<VenueBooking>();
      json['bookings'].forEach((v) {
        bookings.add(new VenueBooking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.bookings != null) {
      data['bookings'] = this.bookings.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VenueBooking implements Booking {
  String id;
  int netPayment;
  String status;
  UserAds property;
  String paymentStatus;

  VenueBooking({this.id, this.netPayment, this.status, this.property});

  VenueBooking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    netPayment = json['netPayment'];
    status = json['status'];
    paymentStatus = json['paymentStatus'];
    property = json['property'] != null
        ? new UserAds.fromJson(json['property'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['netPayment'] = this.netPayment;
    data['status'] = this.status;
    if (this.property != null) {
      data['property'] = this.property.toJson();
    }
    return data;
  }
}
