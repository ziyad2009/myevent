import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/pojos/my_service_bookings.dart';
import 'package:myevents/widgets/upload_receipt_dialog.dart';
import 'package:transparent_image/transparent_image.dart';

class ServiceBookingWidget extends StatelessWidget {
  final ServiceBooking serviceBooking;

  const ServiceBookingWidget({Key key, this.serviceBooking}) : super(key: key);
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
                        serviceBooking.service.name,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      _serviceStatusContainer(),
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
                  Row(
                    children: <Widget>[
                      Text(
                        "SAR ${serviceBooking.netPayment}",
                        style:
                            TextStyle(color: Colors.green[700], fontSize: 18),
                      ),
                      Visibility(
                        visible: serviceBooking.status == "confirmed" &&
                            serviceBooking.paymentStatus == "unpaid",
                        child: OutlineButton(
                          onPressed: () async {
                            List<Asset> selectedReceipt = await loadAssets();
                            if (selectedReceipt.isNotEmpty) {
                              showDialog(
                                  context: context,
                                  builder: (context) => UploadReceiptDialog(
                                        targetType: "service",
                                        targetID: serviceBooking.id,
                                        pickedImages: selectedReceipt,
                                      ));
                            }
                          },
                          child: Text(
                            "UPLOAD BANK RECEIPT",
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
