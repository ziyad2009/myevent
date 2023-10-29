import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
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
import 'package:myevents/pojos/upload.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/pojos/venue_options.dart';
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

class UploadAdForm extends StatefulWidget {
  @override
  _UploadAdFormState createState() => _UploadAdFormState();
}

class _UploadAdFormState extends State<UploadAdForm> {
  final _adFormKey = GlobalKey<FormState>();
  final BackendService _backendService = locator<BackendService>();

  // TextEditing Controllers
  TextEditingController _propertyAddressController = TextEditingController();
  TextEditingController _areaController = TextEditingController();
  TextEditingController _spaceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _relationController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

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
  bool _isFeatured = false;

  List<VenueTypes> selectedVenueTypes = List<VenueTypes>();

  Map<String, dynamic> uploadFields = {};

  // Google Maps
  // Completer<GoogleMapController> _controller = Completer();
  // CameraPosition _mapCameraPosition = CameraPosition(
  //   target: LatLng(37.42796133580664, -122.085749655962),
  //   zoom: 14.4746,
  // );
  // Mode _mode = Mode.overlay;
  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  // final homeScaffoldKey = GlobalKey<ScaffoldState>();
  // final searchScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: homeScaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: Text("Upload New Ad"),
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
                  _pickedImages.length == 0 && !_isFeatured
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
                                          _isFeatured = await videoService
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
                              _isFeatured
                                  ? SizedBox(
                                      height: 150,
                                      width: 200,
                                      child: VideoPreviewWidget(
                                        dataSourceType: DataSourceType.file,
                                        localFile:
                                            videoService.getPickedVideo(),
                                        removeVideoCallback: () {
                                          _isFeatured = false;
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
                        _isFeatured,
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
                              _isFeatured =
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
                        if (_isFeatured) {
                          videoService.clearPickedVideo();
                          _isFeatured = false;
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
                    controller: _titleController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                    ],
                    decoration: new InputDecoration(
                      labelText: "Property Title",
                      contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      hintText: "This can be name or location of venue",
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
                  SizedBox(
                    height: 18,
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
                            hintText: "Property Address",
                            hintStyle: TextStyle(color: Colors.grey),
                            labelText: "Address"),
                        validator: (val) => val.toString().isNotEmpty
                            ? null
                            : 'Property address is a required field',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4),
                    child:
                        Text("Click on the GPS button for accurate location"),
                  ),
                  // SizedBox(height: 8),
                  // SizedBox(
                  //   height: 300,
                  //   child: GoogleMap(
                  //     mapType: MapType.normal,
                  //     // myLocationEnabled: true,
                  //     // myLocationButtonEnabled: true,
                  //     initialCameraPosition: _mapCameraPosition,
                  //     markers: Set<Marker>.of(markers.values),
                  //     onMapCreated: (GoogleMapController controller) {
                  //       if (!_controller.isCompleted)
                  //         _controller.complete(controller);
                  //     },
                  //   ),
                  // ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            DatePicker.showDatePicker(context,
                                pickerMode: DateTimePickerMode.time,
                                onConfirm: (DateTime dateTime, List<int> temp) {
                              setState(() {
                                startTime = dateTime;
                                start = TimeOfDay.fromDateTime(startTime);
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4)),
                            height: 64,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  startTime == null
                                      ? "Opening Time"
                                      : "${start?.format(context)?.toString()}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(Icons.access_time, color: Colors.grey[600])
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            DatePicker.showDatePicker(context,
                                pickerMode: DateTimePickerMode.time,
                                onConfirm: (DateTime dateTime, List<int> temp) {
                              setState(() {
                                endTime = dateTime;
                                end = TimeOfDay.fromDateTime(endTime);
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4)),
                            height: 64,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  endTime == null
                                      ? "Closing Time"
                                      : "${end?.format(context)?.toString()}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(Icons.access_time, color: Colors.grey[600])
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4)),
                          child: ListTile(
                            title: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              controller: _spaceController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: new InputDecoration(
                                contentPadding: EdgeInsets.all(4),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                labelText: "Space",
                                hintText: "Space",
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              validator: (val) => val.isNotEmpty
                                  ? null
                                  : 'Accomodation is a required field',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4)),
                          child: ListTile(
                            title: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              controller: _areaController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: new InputDecoration(
                                contentPadding: EdgeInsets.all(4),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                labelText: "Area",
                                hintText: "Area(m²)",
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              validator: (val) => val.isNotEmpty
                                  ? null
                                  : 'Area is a required field',
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  sectionHeader("Space Best For"),
                  SizedBox(
                    height: 18,
                  ),
                  Query(
                      options: QueryOptions(documentNode: gql(getVenueTypes)),
                      builder: (QueryResult result,
                          {VoidCallback refetch, FetchMore fetchMore}) {
                        if (result.loading)
                          return LinearProgressIndicator();
                        else if (result.hasException)
                          return Text(
                              "Sorry, Venue types are not avaibale right now.",
                              style: TextStyle(color: Colors.grey));
                        else {
                          VenueOptions venueOptions =
                              VenueOptions.fromJson(result.data);
                          return Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8.0,
                                children: venueOptions.venueTypes
                                    .map(
                                      (VenueTypes venueType) => InputChip(
                                        selected: selectedVenueTypes
                                            .contains(venueType),
                                        onSelected: (perkSelected) {
                                          if (perkSelected)
                                            selectedVenueTypes.add(venueType);
                                          else
                                            selectedVenueTypes
                                                .remove(venueType);

                                          setState(() {});
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        showCheckmark: true,
                                        checkmarkColor: primaryColor,
                                        label: Text(venueType.typeName,
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          );
                        }
                      }),
                  SizedBox(
                    height: 18,
                  ),
                  sectionHeader("Pricing"),
                  SizedBox(
                    height: 18,
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
                        : 'Rent is a requried field',
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                      onTap: () async {
                        DatePicker.showDatePicker(context,
                            minDateTime: DateTime.now(),
                            // locale: AppLocalizations.of(context)
                            //             .locale
                            //             .languageCode ==
                            //         "en"
                            //     ? DateTimePickerLocale.en_us
                            //     : DateTimePickerLocale.ar,
                            dateFormat: "yyyy-MMMM-dd", onConfirm:
                                (DateTime selectedAvailable, List<int> temp) {
                          availableTill = selectedAvailable;
                          setState(() {});
                        });
                      },
                      title: availableTill == null
                          ? Text("Available Till")
                          : Text(formattedDateTime(
                              availableTill.toIso8601String())),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    controller: _relationController,
                    keyboardType: TextInputType.text,
                    maxLength: 10,
                    decoration: new InputDecoration(
                      labelText: "Ownership Status",
                      contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      hintText: "How are you related to this property?",
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
                  SizedBox(height: 12),
                  sectionHeader("Perks"),
                  SizedBox(height: 18),
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
                    height: 18,
                  ),
                  Text("Review your information and click on post."),
                  Text(
                      "By posting, you are agreeing to the Terms & Conditions."),
                  Visibility(
                    visible: _isFeatured,
                    child: Text(
                        "Uploading a premium ad can take a little longer. Thank you for understanding!"),
                  ),
                  Visibility(
                    visible: _inAsync,
                    child: LinearProgressIndicator(),
                  ),
                  Mutation(
                    options: MutationOptions(
                        documentNode: gql(createUserAd),
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
                          AdDetail adDetail =
                              AdDetail.fromJson(resultData["createUserAd"]);
                          setState(() {
                            _inAsync = false;
                            _statusString = "POSTED";
                          });
                          showDialog<bool>(
                                  context: context,
                                  builder: (context) => PostAdDialog())
                              .then((bool value) {
                            if (value) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SingleAdPage(
                                      classfiedAdID: adDetail.userAd.id),
                                ),
                              );
                            }
                          });
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
                        if (_isFeatured) {
                          bool premiumConsent = await showDialog<bool>(
                              context: context,
                              builder: (context) =>
                                  PremiumAdConfirmationDialog());
                          if (_isFeatured && !premiumConsent) {
                            BotToast.showText(
                                text:
                                    "Please remove the showcase video to upload a regular ad");
                            return;
                          }
                        }
                        if (_inAsync) return;
                        if (_statusString == "POSTED") return;
                        if (validateFields()) {
                          setState(() {
                            _inAsync = true;
                            _statusString = "POSTING...";
                            // Removing focus from any active TextFields
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          });
                          if (Provider.of<UserBasic>(context).id.isNotEmpty) {
                            List<UploadResponse> uploadResponses =
                                <UploadResponse>[];
                            String uploadResponse = await _backendService
                                .multipleFileUploads(_pickedImages);

                            List<dynamic> decoded = json.decode(uploadResponse);
                            if (decoded != null && decoded.isNotEmpty) {
                              for (var uploadEntry in decoded) {
                                uploadResponses
                                    .add(UploadResponse.fromJson(uploadEntry));
                              }
                              if (_isFeatured) {
                                String uploadedVideoID =
                                    await videoService.httpVideoUpload();
                                uploadFields["propertyVideo"] = uploadedVideoID;
                                print("uploaded video id: $uploadedVideoID");
                              }
                              uploadFields["featuredImage"] = uploadResponses
                                  .elementAt(primaryImageIndex)
                                  .sId;
                              uploadFields["adImages"] = uploadResponses
                                  .map((UploadResponse resp) => resp.sId)
                                  .toList();
                              uploadFields["title"] = _titleController.text;
                              uploadFields["seller"] =
                                  Provider.of<UserBasic>(context).id;
                              uploadFields["views"] = 0;
                              uploadFields["venueAddress"] =
                                  _propertyAddressController.text;
                              uploadFields["venueLat"] =
                                  currentLocation?.latitude;
                              uploadFields["venueLon"] =
                                  currentLocation?.longitude;
                              uploadFields["venueTypes"] =
                                  selectedVenueTypes.map((e) => e.id).toList();
                              uploadFields["area"] =
                                  int.parse(_areaController.text);
                              uploadFields["accommodation"] =
                                  int.parse(_spaceController.text);
                              final now = new DateTime.now();
                              startTime = DateTime(now.year, now.month, now.day,
                                  start.hour, start.minute);
                              endTime = DateTime(now.year, now.month, now.day,
                                  end.hour, end.minute);
                              uploadFields["timeStart"] = startTime
                                  .toIso8601String()
                                  .split('T')
                                  .elementAt(1);
                              uploadFields["timeEnd"] = endTime
                                  .toIso8601String()
                                  .split('T')
                                  .elementAt(1);
                              uploadFields["description"] =
                                  _descriptionController.text;
                              uploadFields["price"] =
                                  int.parse(_priceController.text);
                              uploadFields["availableTill"] =
                                  availableTill.toUtc().toIso8601String();
                              uploadFields["adStatus"] = "Active";
                              uploadFields["sellerDesignation"] =
                                  _relationController.text;
                              uploadFields["isFeatured"] = _isFeatured;
                              uploadFields["perkList"] =
                                  selectedPerks.map((e) => e.id).toList();
                              runMutation({
                                "input": <String, dynamic>{"data": uploadFields}
                              });
                            }
                          }
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

  // Future<void> _handlePressButton(String locationType) async {
  //   // show input autocomplete with selected mode
  //   // then get the Prediction selected
  //   Prediction p = await PlacesAutocomplete.show(
  //     context: context,
  //     apiKey: kGoogleApiKey,
  //     onError: onError,
  //     mode: _mode,
  //     language: "en",
  //     components: [Component(Component.country, "sa")], // sa = Saudi Arabi
  //   );

  //   displayPrediction(p, homeScaffoldKey.currentState, locationType);
  // }

  // void onError(PlacesAutocompleteResponse response) {
  //   homeScaffoldKey.currentState.showSnackBar(
  //     SnackBar(content: Text(response.errorMessage)),
  //   );
  // }

  // Future<Null> displayPrediction(
  //     Prediction p, ScaffoldState scaffold, String locationType) async {
  //   if (p != null) {
  //     PlacesDetailsResponse detail =
  //         await _places.getDetailsByPlaceId(p.placeId);
  //     final lat = detail.result.geometry.location.lat;
  //     final lng = detail.result.geometry.location.lng;
  //     // scaffold.showSnackBar(
  //     //   SnackBar(content: Text("${p.description} - $lat/$lng")),
  //     // );

  //     final GoogleMapController controller = await _controller.future;
  //     String markerIdVal = locationType;
  //     final MarkerId markerId = MarkerId(markerIdVal);
  //     final Marker marker = Marker(
  //         draggable: true,
  //         markerId: markerId,
  //         position: LatLng(
  //           lat,
  //           lng,
  //         ),
  //         infoWindow:
  //             InfoWindow(title: markerIdVal, snippet: '$locationType Location'),
  //         onTap: () {},
  //         onDragEnd: (value) {
  //           if (locationType == "pickup") {
  //             //   TLocation newLocation = TLocation(
  //             //       description: "Pin Location",
  //             //       latitude: value.latitude.toString(),
  //             //       longitude: value.longitude.toString());
  //             //   pickUpTLocation = newLocation;
  //             // } else if (locationType == "dropoff") {
  //             // TLocation newLocation = TLocation(
  //             //     description: "Pin Location",
  //             //     latitude: value.latitude.toString(),
  //             //     longitude: value.longitude.toString());
  //             // dropOffTLocation = newLocation;
  //           }
  //           setState(() {});
  //         });
  //     CameraPosition _selectedPosition = CameraPosition(
  //       target: LatLng(lat, lng),
  //       zoom: 14.4746,
  //       bearing: 192.8334901395799,
  //     );
  //     controller
  //         .animateCamera(CameraUpdate.newCameraPosition(_selectedPosition));

  //     setState(() {
  //       markers[markerId] = marker;
  //     });
  //   }
  // }

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

  Future<DateTime> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1970, 8),
        lastDate: DateTime(2101));

    return picked;
  }

  Widget _selectTimeDialog(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Pick time limit", style: TextStyle(fontSize: 20)),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                leading: Icon(Icons.access_time),
                title: Text(start?.format(context)?.toString() ?? "Start Time"),
                onTap: () async {
                  start = await openTimePicker(context);
                  setState(() {});
                },
              ),
            ),
            Text("Till"),
            Expanded(
              child: ListTile(
                leading: Icon(Icons.access_time),
                title: Text(end?.format(context)?.toString() ?? "End Time"),
                onTap: () async {
                  end = await openTimePicker(context);
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 18),
        ButtonBar(
          children: <Widget>[
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                "Done",
                style: TextStyle(color: primaryColor),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        )
      ],
    );
  }

  Future<TimeOfDay> openTimePicker(BuildContext context) async {
    TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          );
        });
    return picked;
  }

  bool validateFields() {
    if (_pickedImages.isEmpty ||
        _propertyAddressController.text.isEmpty ||
        _titleController.text.isNotEmpty ||
        _areaController.text.isEmpty ||
        selectedVenueTypes.isEmpty ||
        _spaceController.text.isEmpty ||
        start == null ||
        end == null ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        availableTill == null)
      return false;
    else
      return true;
  }
}
