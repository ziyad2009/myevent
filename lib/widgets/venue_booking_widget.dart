import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/pojos/my_venue_bookings.dart';
import 'package:myevents/widgets/upload_receipt_dialog.dart';
import 'package:transparent_image/transparent_image.dart';

class VenueBookingWidget extends StatelessWidget {
  final VenueBooking venueBooking;

  const VenueBookingWidget({Key key, this.venueBooking}) : super(key: key);
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
                height: 150,
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
                      Text(
                        venueBooking.property.title,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      _venueStatusContainer()
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
                      Visibility(
                        visible: venueBooking.status == "confirmed" &&
                            venueBooking.paymentStatus == "pending",
                        child: OutlineButton(
                          onPressed: () async {
                            List<Asset> selectedReceipt = await loadAssets();
                            if (selectedReceipt.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => UploadReceiptDialog(
                                  targetType: "userAd",
                                  targetID: venueBooking.id,
                                  pickedImages: selectedReceipt,
                                ),
                              );
                            }
                          },
                          child: Text(
                            "ADD RECEIPT",
                            style: TextStyle(
                                color: exoticPurple,
                                letterSpacing: 1.25,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  )
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
          "Waiting",
          style: TextStyle(
              color: Colors.orange, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      );
  }

  Future<List<Asset>> loadAssets() async {
    List<Asset> resultList;
    try {
      resultList =
          await MultiImagePicker.pickImages(maxImages: 1, enableCamera: true);
      return resultList;
    } on Exception catch (e) {
      print(e.toString());
      return <Asset>[];
    }
  }
}
