import 'package:bot_toast/bot_toast.dart';
import 'package:calendarro/calendarro.dart';
import 'package:calendarro/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/models/booking_models/create_booking_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/viewstate.dart';
import 'package:provider/provider.dart';

class BookNowPage extends StatefulWidget {
  final String targetType;
  final String targetID;
  final String targetName;
  final int perDayPrice;
  final bool isEditingMode;
  final String editBookingID;

  const BookNowPage(
      {Key key,
      this.targetType,
      this.targetID,
      this.targetName,
      this.perDayPrice,
      this.isEditingMode,
      this.editBookingID})
      : super(key: key);

  @override
  _BookNowPageState createState() => _BookNowPageState();
}

class _BookNowPageState extends State<BookNowPage> {
  Set<DateTime> bookingDates = Set<DateTime>();
  int selectedMonth = DateTime.now().month - 1;
  List<String> monthsList = [
    "January",
    "Febuary",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditingMode ? "Update Booking" : "Book ${widget.targetName}",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BaseView<CreateBookingModel>(
        onModelReady: (model) async {
          await model.fetchVendorReservedDates(
              widget.targetType, widget.targetID);
          if (widget.isEditingMode) {
            await model.editableOfflineDates(
                widget.targetType, widget.targetID, widget.editBookingID);
            model.mergeCustomerAndVendorReservedDates();
          } else {
            await model.fetchOfflineDates(widget.targetType, widget.targetID);
            model.mergeCustomerAndVendorReservedDates();
          }
          if (widget.isEditingMode) {
            if (widget.targetType == "userAd") {
              await model.fetchVenueBookingDates(widget.editBookingID);
              bookingDates.addAll(model.venueBookingDates.booking.bookedDates
                  .map((e) => e.date)
                  .toList());
            } else {
              await model.fetchServiceBookingDates(widget.editBookingID);
              bookingDates.addAll(model
                  .serviceBookingDates.serviceBooking.bookedDates
                  .map((e) => e.date)
                  .toList());
            }
          }
        },
        builder: (context, model, child) {
          if (model.state == ViewState.Busy)
            return Center(child: CircularProgressIndicator());
          else
            return Container(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Text(
                      widget.isEditingMode
                          ? "Update booking dates for ${widget.targetName}"
                          : "Select dates to book ${widget.targetName}",
                      style: TextStyle(color: primaryColor, fontSize: 24),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        sectionHeader("Month"),
                        SizedBox(width: 16),
                        DropdownButton<String>(
                          value: monthsList.elementAt(selectedMonth),
                          hint: Text("Category"),
                          items: monthsList.map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value,
                                  style: TextStyle(fontSize: 20)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedMonth = monthsList.indexOf(newValue);
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Calendarro(
                      selectionMode: SelectionMode.MULTI,
                      unavailableDates: model.getUnavailableDates(),
                      selectedDates: bookingDates
                          .map((e) => DateTime(e.year, e.month, e.day))
                          .toList(),
                      startDate: DateUtils.getFirstDayOfMonth(
                        DateTime(DateTime.now().year, selectedMonth + 1),
                      ),
                      endDate: DateUtils.getLastDayOfMonth(
                        DateTime(DateTime.now().year, selectedMonth + 1),
                      ),
                      displayMode: DisplayMode.MONTHS,
                      onTap: (DateTime selected) {
                        if (selected.isBefore(DateTime.now())) {
                          BotToast.showText(
                              text: "Dates past today are not available");
                          return;
                        }
                        if (!bookingDates.add(selected)) {
                          bookingDates.remove(selected);
                        }
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.maxFinite,
                      child: RaisedButton(
                        color: primaryColor,
                        onPressed: bookingDates.isEmpty
                            ? null
                            : () async {
                                if (bookingDates.isEmpty) {
                                  BotToast.showText(
                                      text:
                                          "Please select some booking dates first!");
                                  return;
                                }
                                if (model.state == ViewState.Success) return;
                                if (widget.isEditingMode) {
                                  Map<String, dynamic> bookingPayload = {};
                                  bookingPayload["paymentStatus"] = "pending";
                                  bookingPayload["netPayment"] =
                                      widget.perDayPrice * bookingDates.length;
                                  bookingPayload["status"] = "waiting";
                                  bookingPayload["booker"] =
                                      Provider.of<UserBasic>(context).id;
                                  if (widget.targetType == "userAd")
                                    await model.modifyVenueBooking(
                                        widget.targetID,
                                        widget.targetType,
                                        bookingPayload,
                                        bookingDates,
                                        widget.editBookingID);
                                  else
                                    await model.modifyServiceBooking(
                                        widget.targetID,
                                        widget.targetType,
                                        bookingPayload,
                                        bookingDates,
                                        widget.editBookingID);
                                  BotToast.showText(text: "✅ Booking Updated");
                                } else {
                                  Map<String, dynamic> bookingPayload = {};
                                  bookingPayload["paymentStatus"] = "pending";
                                  bookingPayload["netPayment"] =
                                      widget.perDayPrice * bookingDates.length;
                                  bookingPayload["status"] = "waiting";
                                  bookingPayload["booker"] =
                                      Provider.of<UserBasic>(context).id;
                                  if (widget.targetType == "userAd")
                                    await model.submitVenueBooking(
                                        widget.targetID,
                                        widget.targetType,
                                        bookingPayload,
                                        bookingDates);
                                  else
                                    await model.submitServiceBooking(
                                        widget.targetID,
                                        widget.targetType,
                                        bookingPayload,
                                        bookingDates);
                                  BotToast.showText(
                                      text: "✅ Booking Request Submitted");
                                }

                                Navigator.pop(context);
                              },
                        child: Text(
                          widget.isEditingMode
                              ? "UPDATE BOOKING"
                              : "SUBMIT BOOKING",
                          style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.25,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
        },
      ),
    );
  }
}
