import 'package:myevents/pojos/booking_class.dart';
import 'package:myevents/pojos/service_items.dart';

class MyServiceBookings {
  List<ServiceBooking> bookings;

  MyServiceBookings({this.bookings});

  MyServiceBookings.fromJson(Map<String, dynamic> json) {
    if (json['serviceBookings'] != null) {
      bookings = new List<ServiceBooking>();
      json['serviceBookings'].forEach((v) {
        bookings.add(new ServiceBooking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.bookings != null) {
      data['serviceBookings'] = this.bookings.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceBooking implements Booking {
  String id;
  int netPayment;
  String status;
  String paymentStatus;
  Services service;

  ServiceBooking({this.id, this.netPayment, this.status, this.service});

  ServiceBooking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    netPayment = json['netPayment'];
    paymentStatus = json['paymentStatus'];
    status = json['status'];
    service =
        json['service'] != null ? new Services.fromJson(json['service']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['netPayment'] = this.netPayment;
    data['status'] = this.status;
    if (this.service != null) {
      data['service'] = this.service.toJson();
    }
    return data;
  }
}
