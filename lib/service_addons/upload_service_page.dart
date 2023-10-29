import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/backend/video_service.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/common/custom_animation.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/pages/single_page.dart';
import 'package:myevents/pojos/ad_detail.dart';
import 'package:myevents/pojos/all_perks.dart';
import 'package:myevents/pojos/perk_list.dart';
import 'package:myevents/pojos/service_detail.dart';
import 'package:myevents/pojos/upload.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/service_addons/addon_detail_page.dart';
import 'package:myevents/widgets/confirm_dialog.dart';
import 'package:myevents/widgets/info_bottom_sheet.dart';
import 'package:myevents/widgets/modal_bottom_sheet.dart';
import 'package:myevents/widgets/post_ad_dialog.dart';
import 'package:myevents/widgets/premium_ad_confirm.dart';
import 'package:myevents/widgets/upload_choice_dialog.dart';
import 'package:myevents/widgets/video_preview_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class UploadServiceForm extends StatefulWidget {
  @override
  _UploadServiceFormState createState() => _UploadServiceFormState();
}

class _UploadServiceFormState extends State<UploadServiceForm> {
  final _adFormKey = GlobalKey<FormState>();
  final BackendService _backendService = locator<BackendService>();

  // TextEditing Controllers
  TextEditingController _propertyAddressController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _serviceNameController = TextEditingController();

  TimeOfDay start;
  TimeOfDay end;
  DateTime startTime;
  DateTime endTime;
  DateTime availableTill;
  List<Asset> _pickedImages = List<Asset>();
  Position currentLocation;
  String category;
  int primaryImageIndex = 0;
  VideoService videoService = VideoService();

  List<Perks> selectedPerks = List<Perks>();

  bool _inAsync = false;
  String _statusString = "POST";

  // This bool checks whether the uploaded ad will be premium or not.
  // Premium ad has a video and may or may not have any photos
  bool _isPremium = false;

  Map<String, dynamic> uploadFields = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Upload New Service"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () async {
            bool shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) => DeleteConfirmationDialog(
                      dialogTitle: "Are you sure?",
                      deleteContent:
                          "Any information you have filled will be lost",
                      yesButton: "Yes, Go Back",
                      noButton: "Stay here",
                    ));
            if (shouldPop != null) {
              if (shouldPop) Navigator.pop(context);
            }
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          bool shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => DeleteConfirmationDialog(
                    dialogTitle: "Are you sure?",
                    deleteContent:
                        "Any information you have filled will be lost",
                    yesButton: "Yes, Go Back",
                    noButton: "Stay here",
                  ));
          if (shouldPop == null) return false;
          return shouldPop;
        },
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 16),
          child: SingleChildScrollView(
            child: Form(
              key: _adFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _pickedImages.length == 0 && !_isPremium
                      ? DottedBorder(
                          radius: Radius.circular(8),
                          borderType: BorderType.Rect,
                          color: Colors.grey[400],
                          strokeWidth: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[300],
                            ),
                            width: double.maxFinite,
                            height: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.add_a_photo),
                                  onPressed: () async {
                                    showDialog<bool>(
                                      context: context,
                                      builder: (context) =>
                                          UploadChoiceDialog(),
                                    ).then((value) async {
                                      if (value != null) {
                                        if (!value) {
                                          _pickedImages = await loadAssets();
                                          setState(() {});
                                        } else {
                                          _isPremium = await videoService
                                              .launchVideoPicker();

                                          setState(() {});
                                        }
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  "Tap here to upload photos or video",
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 150,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              _isPremium
                                  ? SizedBox(
                                      height: 150,
                                      width: 200,
                                      child: VideoPreviewWidget(
                                        dataSourceType: DataSourceType.file,
                                        localFile:
                                            videoService.getPickedVideo(),
                                        removeVideoCallback: () {
                                          _isPremium = false;
                                          videoService.clearPickedVideo();
                                          setState(() {});
                                        },
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _pickedImages.length,
                                  itemBuilder: (context, index) =>
                                      GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        primaryImageIndex = index;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: <Widget>[
                                          AssetThumb(
                                            height: 200,
                                            width: 200,
                                            asset:
                                                _pickedImages.elementAt(index),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.remove_circle,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              _pickedImages.removeAt(index);
                                              setState(() {});
                                            },
                                          ),
                                          index == primaryImageIndex
                                              ? Positioned(
                                                  bottom: 8,
                                                  left: 8,
                                                  child: Icon(
                                                    Icons.featured_video,
                                                    color: primaryColor,
                                                    size: 20.0,
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                  Visibility(
                    visible: (_pickedImages.isNotEmpty &&
                            _pickedImages.length < 5) ||
                        _isPremium,
                    child: OutlineButton.icon(
                      onPressed: () async {
                        showDialog<bool>(
                          context: context,
                          builder: (context) => UploadChoiceDialog(),
                        ).then((value) async {
                          if (value != null) {
                            if (!value) {
                              List<Asset> addMore = await loadAssets();
                              _pickedImages.addAll(addMore);
                              setState(() {});
                            } else {
                              _isPremium =
                                  await videoService.launchVideoPicker();
                              setState(() {});
                            }
                          }
                        });
                      },
                      icon: Icon(Icons.add, color: primaryColor),
                      label: Text("Add More"),
                    ),
                  ),
                  Visibility(
                    visible: _pickedImages.length != 0,
                    child: OutlineButton.icon(
                      icon: Icon(Icons.delete_sweep, color: Colors.grey),
                      label: const Text(
                        "Clear All",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        _pickedImages.clear();
                        if (_isPremium) {
                          videoService.clearPickedVideo();
                          _isPremium = false;
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(height: 18),
                  sectionHeader("General Information"),
                  SizedBox(
                    height: 18,
                  ),
                  TextFormField(
                    controller: _serviceNameController,
                    keyboardType: TextInputType.text,
                    maxLength: 30,
                    textCapitalization: TextCapitalization.words,
                    decoration: new InputDecoration(
                      labelText: "Service Title",
                      contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      hintText: "What service are you providing?",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 0.0),
                      ),
                    ),
                    validator: (val) => val.toString().isNotEmpty
                        ? null
                        : 'This is a necessary field',
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                      trailing: IconButton(
                        icon: Icon(
                          Icons.gps_fixed,
                          color: currentLocation == null
                              ? Colors.grey
                              : Colors.green,
                        ),
                        onPressed: () async {
                          if (await checkAndRequestLocationPermissions()) {
                            Position position = await Geolocator()
                                .getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high);
                            if (position == null) {
                              Fluttertoast.showToast(
                                  msg:
                                      "GPS locations is unavailable! Please enter manually",
                                  toastLength: Toast.LENGTH_LONG);
                            } else {
                              currentLocation = position;
                              List<Placemark> placemark = await Geolocator()
                                  .placemarkFromCoordinates(
                                      currentLocation.latitude,
                                      currentLocation.longitude);
                              Fluttertoast.showToast(
                                  msg: "Current location set as address",
                                  toastLength: Toast.LENGTH_SHORT);
                              setState(() {
                                _propertyAddressController.text =
                                    "${placemark.first.name} ${placemark.first.subLocality} ${placemark.first.locality} ${placemark.first.subAdministrativeArea} ${placemark.first.subThoroughfare} ${placemark.first.thoroughfare}";
                              });
                            }
                          } else {
                            BotToast.showText(
                                text:
                                    "Permission Denined. Current location not set");
                          }
                        },
                      ),
                      title: TextFormField(
                        controller: _propertyAddressController,
                        decoration: new InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Service Location",
                            hintStyle: TextStyle(color: Colors.grey),
                            labelText: "Address"),
                        validator: (val) => val.toString().isNotEmpty
                            ? null
                            : 'Service location is a required field',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4),
                    child: Text("Click on the GPS button for current location"),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 300,
                    textInputAction: TextInputAction.done,
                    decoration: new InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      hintText: "Description",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 0.0),
                      ),
                    ),
                    validator: (val) => val.toString().isNotEmpty
                        ? null
                        : 'Description is a requried field',
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  sectionHeader("Pricing"),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    decoration: new InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      hintText: "Rent/Day",
                      labelText: "Rent",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 0.0),
                      ),
                    ),
                    validator: (val) => val.toString().isNotEmpty
                        ? null
                        : 'Rent/Day is a requried field',
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  sectionHeader("Perks"),
                  SizedBox(height: 12),
                  Query(
                    options: QueryOptions(documentNode: gql(fetchPerks)),
                    builder: (QueryResult result,
                        {VoidCallback refetch, FetchMore fetchMore}) {
                      if (result.loading)
                        return LinearProgressIndicator();
                      else {
                        AllPerks perkList = AllPerks.fromJson(result.data);
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              child: Wrap(
                                spacing: 5.0,
                                runSpacing: 3.0,
                                children: perkList.perks
                                    .map(
                                      (Perks tag) => InputChip(
                                        checkmarkColor:
                                            selectedPerks.contains(tag)
                                                ? Colors.white
                                                : null,
                                        label: Text(tag.perkName),
                                        labelStyle: TextStyle(
                                          color: selectedPerks.contains(tag)
                                              ? Colors.white
                                              : Color(0xB2000000),
                                          fontSize: 12.0,
                                        ),
                                        selected: selectedPerks.contains(tag),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(13.0),
                                        ),
                                        backgroundColor: Color(0xFFECECEC),
                                        onSelected: (isSelected) {
                                          setState(() {
                                            if (isSelected)
                                              selectedPerks.add(tag);
                                            else
                                              selectedPerks.remove(tag);
                                          });
                                        },
                                        selectedColor: primaryColor,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text("Review your information and click on post."),
                  Text(
                      "By posting, you are agreeing to the Terms & Conditions of Munasba."),
                  Visibility(
                    visible: _inAsync,
                    child: LinearProgressIndicator(),
                  ),
                  Mutation(
                    options: MutationOptions(
                        documentNode: gql(createServiceAd),
                        update: (Cache cache, QueryResult result) {
                          return result;
                        },
                        onError: (OperationException mutationError) {
                          setState(() {
                            _inAsync = false;
                            _statusString = "POST";
                          });
                          BotToast.showText(
                            textStyle: TextStyle(color: Colors.orange),
                            text:
                                "An error occured: " + mutationError.toString(),
                            duration: Duration(seconds: 3),
                          );
                        },
                        onCompleted: (dynamic resultData) {
                          print(resultData);
                          print(resultData["createService"]);
                          ServiceDetail serviceDetail = ServiceDetail.fromJson(
                              resultData["createService"]);
                          setState(() {
                            _inAsync = false;
                            _statusString = "POSTED";
                          });
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceDetailPage(
                                serviceID: serviceDetail.service.id,
                              ),
                            ),
                          );
                        }),
                    builder: (RunMutation runMutation, QueryResult result) =>
                        RaisedButton.icon(
                      color: primaryColor,
                      label: Text(
                        _statusString,
                        style: raisedTextStyle,
                      ),
                      icon: _statusString == "POSTING..." ||
                              _statusString == "POST"
                          ? Icon(Icons.arrow_upward, color: Colors.white)
                          : Icon(Icons.check, color: Colors.white),
                      onPressed: () async {
                        if (_isPremium) {
                          bool premiumConsent = await showDialog<bool>(
                              context: context,
                              builder: (context) =>
                                  PremiumAdConfirmationDialog());
                          if (_isPremium && !premiumConsent) {
                            BotToast.showText(
                                text:
                                    "Please remove the showcase video to upload a regular ad");
                            return;
                          }
                        }
                        if (_inAsync) return;
                        if (_statusString == "POSTED") return;
                        if (validateFields()) {
                          await encodeDataToUpload();
                          runMutation({
                            "input": <String, dynamic>{"data": uploadFields}
                          });
                        } else {
                          BotToast.showText(
                            text: 'Please fill all fields first!',
                            wrapToastAnimation:
                                (controller, cancel, Widget child) =>
                                    CustomAnimationWidget(
                              controller: controller,
                              child: child,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Asset>> loadAssets() async {
    List<Asset> resultList;
    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 5 - _pickedImages.length, enableCamera: true);
      return resultList;
    } on Exception catch (e) {
      print(e.toString());
      return <Asset>[];
    }
  }

  Future encodeDataToUpload() async {
    setState(() {
      _inAsync = true;
      _statusString = "POSTING...";
      FocusScope.of(context).requestFocus(new FocusNode());
    });
    if (Provider.of<UserBasic>(context).id.isNotEmpty) {
      List<UploadResponse> uploadResponses = <UploadResponse>[];
      String uploadResponse =
          await _backendService.multipleFileUploads(_pickedImages);

      List<dynamic> decoded = json.decode(uploadResponse);
      if (decoded != null && decoded.isNotEmpty) {
        for (var uploadEntry in decoded) {
          uploadResponses.add(UploadResponse.fromJson(uploadEntry));
        }
        if (_isPremium) {
          String uploadedVideoID = await videoService.httpVideoUpload();
          uploadFields["serviceVideo"] = uploadedVideoID;
        }
        uploadFields["serviceFeatureImage"] =
            uploadResponses.elementAt(primaryImageIndex).sId;
        uploadFields["servicePhotos"] =
            uploadResponses.map((UploadResponse resp) => resp.sId).toList();
        uploadFields["name"] = _serviceNameController.text;
        uploadFields["provider"] = Provider.of<UserBasic>(context).id;
        // uploadFields["location"] = {
        //   "latitude": currentLocation?.latitude,
        //   "longitude": currentLocation?.longitude,
        //   "name": _propertyAddressController.text
        // };
        uploadFields["serviceAddress"] = _propertyAddressController.text;
        uploadFields["serviceLat"] = currentLocation?.latitude ?? 0;
        uploadFields["serviceLon"] = currentLocation?.longitude ?? 0;

        uploadFields["description"] = _descriptionController.text;
        uploadFields["pricePerDay"] = int.parse(_priceController.text);
        uploadFields["isPremium"] = _isPremium;

        uploadFields["perkList"] = selectedPerks.map((e) => e.id).toList();
      }
    }
  }

  Future<bool> checkAndRequestSoragePermissions() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      print("permission not granted");
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      return permissions[PermissionGroup.storage] == PermissionStatus.granted;
    } else {
      print("permission is granted");
      return true;
    }
  }

  Future<bool> checkAndRequestLocationPermissions() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationWhenInUse);
    if (permission != PermissionStatus.granted) {
      print("permission not granted");
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      return permissions[PermissionGroup.storage] == PermissionStatus.granted;
    } else {
      print("permission is granted");
      return true;
    }
  }

  bool validateFields() {
    if (_pickedImages.isEmpty ||
        _propertyAddressController.text.isEmpty ||
        _serviceNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty)
      return false;
    else
      return true;
  }
}
