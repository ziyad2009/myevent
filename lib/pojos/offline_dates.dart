import 'package:myevents/common/app_colors.dart';

class OfflineDates {
  String id;
  String dateString;
  DateTime date;
  bool offlineByVendor;

  OfflineDates({this.dateString, this.date});

  OfflineDates.fromJson(Map<String, dynamic> json) {
    dateString = json['unavailable'];
    offlineByVendor = json['offlineByVendor'] ?? false;
    date = DateTime.parse(dateString);
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    return data;
  }

  @override
  bool operator ==(other) {
    return this.date.year == other.date.year &&
        this.date.month == other.date.month &&
        this.date.day == other.date.day;
  }

  @override
  String toString() {
    return formattedDateTime(date.toIso8601String());
  }
}
