import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/pojos/upload.dart';

class UploadReceiptDialog extends StatefulWidget {
  final List<Asset> pickedImages;
  final String targetID;
  final String targetType;

  const UploadReceiptDialog(
      {Key key, this.pickedImages, this.targetID, this.targetType})
      : super(key: key);

  @override
  _UploadReceiptDialogState createState() => _UploadReceiptDialogState();
}

class _UploadReceiptDialogState extends State<UploadReceiptDialog> {
  final BackendService _backendService = locator<BackendService>();
  bool _inAsync = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Upload Bank Receipt",
        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
      ),
      content: AssetThumb(
          asset: widget.pickedImages.elementAt(0), width: 100, height: 100),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            BotToast.showText(text: "Upload cancelled");
            Navigator.pop(context);
          },
          child: Text(
            "CANCEL",
            style: TextStyle(
                color: Colors.grey,
                letterSpacing: 1.25,
                fontWeight: FontWeight.w600),
          ),
        ),
        Mutation(
          options: MutationOptions(
              documentNode: gql(widget.targetType == "userAd"
                  ? updateVenueBooking
                  : updateServiceBooking),
              onError: (OperationException e) {
                BotToast.showText(text: e.toString());
                Navigator.pop(context);
              },
              onCompleted: (dynamic data) {
                BotToast.showText(text: "✅ Receipt Uploaded");
                Navigator.pop(context);
              }),
          builder: (RunMutation runMutation, QueryResult result) {
            return _inAsync
                ? SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : FlatButton(
                    onPressed: () async {
                      setState(() {
                        _inAsync = true;
                      });
                      List<UploadResponse> uploadResponses = <UploadResponse>[];
                      String uploadResponse = await _backendService
                          .multipleFileUploads(widget.pickedImages);

                      List<dynamic> decoded = json.decode(uploadResponse);
                      if (decoded != null && decoded.isNotEmpty) {
                        for (var uploadEntry in decoded) {
                          uploadResponses
                              .add(UploadResponse.fromJson(uploadEntry));
                        }
                        runMutation({
                          "field": {
                            "where": {"id": widget.targetID},
                            "data": {
                              "invoiceImage": uploadResponses.elementAt(0).sId,
                              "paymentStatus": "submitted"
                            }
                          }
                        });
                      }
                    },
                    child: Text(
                      "UPLOAD",
                      style: TextStyle(
                          color: exoticPurple,
                          letterSpacing: 1.25,
                          fontWeight: FontWeight.w600),
                    ),
                  );
          },
        )
      ],
    );
  }
}
