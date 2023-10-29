import 'package:bot_toast/bot_toast.dart';
import 'package:calendarro/calendarro.dart';
import 'package:calendarro/date_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:myevents/backend/video_service.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/common/custom_animation.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/models/ad_edit_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pojos/ad_detail.dart';
import 'package:myevents/pojos/all_perks.dart';
import 'package:myevents/pojos/offline_dates.dart';
import 'package:myevents/pojos/perk_list.dart';
import 'package:myevents/pojos/upload.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/pojos/venuE_options.dart';
import 'package:myevents/widgets/confirm_dialog.dart';
import 'package:myevents/widgets/premium_ad_confirm.dart';
import 'package:myevents/widgets/upload_choice_dialog.dart';
import 'package:myevents/widgets/video_preview_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class EditAdForm extends StatefulWidget {
  final String editAdID;
  EditAdForm({this.editAdID});
  @override
  _UploadAdFormState createState() => _UploadAdFormState();
}

class _UploadAdFormState extends State<EditAdForm> {
  final _adFormKey = GlobalKey<FormState>();

  // TextEditing Controllers
  TextEditingController _propertyAddressController = TextEditingController();
  TextEditingController _areaController = TextEditingController();
  TextEditingController _spaceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  TimeOfDay start;
  TimeOfDay end;
  DateTime startTime;
  DateTime endTime;
  DateTime availableTill;
  List<dynamic> venueImages = List<dynamic>();
  Position currentLocation;
  int primaryImageIndex = 0;
  String _isoAppend = "2012-12-12T";
  bool _isPremium = false;
  bool _isVideoAd = false;

  VideoService videoService = VideoService();

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

  Map<String, dynamic> uploadFields = {};
  Set<DateTime> newSelectedDates = new Set<DateTime>();
  List<VenueTypes> selectedVenueTypes = List<VenueTypes>();
  List<Perks> selectedPerks = List<Perks>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Ad"),
        elevation: 0,
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
                          "Any updates made after last save might be lost",
                      yesButton: "Yes, Go Back",
                      noButton: "Stay here",
                    ));
            if (shouldPop != null) {
              if (shouldPop) Navigator.pop(context);
            }
          },
        ),
      ),
      body: BaseView<AdEditModel>(onModelReady: (model) async {
        await model.fetchAdToEdit(widget.editAdID);
        if (model.adDetail.userAd != null) {
          _runPreEditTasks(model.adDetail);
        }
      }, builder: (context, model, child) {
        if (model.editState == EditVenueStates.FETCHING)
          return Center(child: CircularProgressIndicator());
        else if (model.editState == EditVenueStates.FETCH_FAILED ||
            model.editState == EditVenueStates.SAVE_FAILED)
          return Scaffold(
            body: Center(
              child: Text(
                "Sorry, editing is not working right now. Try again in a few minutes! (${model.lastError})",
                textAlign: TextAlign.center,
                style: TextStyle(color: exoticPurple, fontSize: 18),
              ),
            ),
          );
        else
          return WillPopScope(
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
                      venueImages.length == 0 && !_isPremium
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
                                child: Center(
                                  child: IconButton(
                                    icon: Icon(Icons.add_a_photo),
                                    onPressed: () async {
                                      List<Asset> newPickedImages =
                                          List<Asset>();
                                      newPickedImages = await loadAssets();
                                      venueImages.addAll(newPickedImages);
                                      setState(() {});
                                    },
                                  ),
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
                                            dataSourceType: _isPremium &&
                                                    videoService.isVideoPicked()
                                                ? DataSourceType.file
                                                : DataSourceType.network,
                                            localFile:
                                                videoService.getPickedVideo(),
                                            networkFileUrl: model
                                                    .adDetail
                                                    .userAd
                                                    .propertyVideo
                                                    ?.url ??
                                                null,
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
                                      itemCount: venueImages.length,
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
                                              (venueImages.elementAt(index)
                                                      is Asset)
                                                  ? AssetThumb(
                                                      height: 200,
                                                      width: 200,
                                                      asset: venueImages
                                                              .elementAt(index)
                                                          as Asset,
                                                    )
                                                  : SizedBox(
                                                      height: 200,
                                                      width: 200,
                                                      child: Image.network(
                                                          (venueImages.elementAt(
                                                                      index)
                                                                  as UploadResponse)
                                                              .url),
                                                    ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.remove_circle,
                                                  size: 18,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  venueImages.removeAt(index);
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
                              ),
                            ),
                      Visibility(
                        visible: (venueImages.isNotEmpty &&
                                venueImages.length < 5) ||
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
                                  venueImages.addAll(addMore);
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
                        visible: venueImages.length != 0,
                        child: OutlineButton.icon(
                          icon: Icon(Icons.delete_sweep, color: Colors.grey),
                          label: const Text(
                            "Clear All",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            venueImages.clear();
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
                        controller: _titleController,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                        ],
                        decoration: new InputDecoration(
                          labelText: "Property Title",
                          hintText: "This can be name or location of venue",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 0.0),
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
                                  setState(() {
                                    _propertyAddressController.text =
                                        "${placemark.first.name} ${placemark.first.subLocality} ${placemark.first.locality} ${placemark.first.subAdministrativeArea} ${placemark.first.subThoroughfare} ${placemark.first.thoroughfare}";
                                  });
                                }
                              }
                            },
                          ),
                          title: TextFormField(
                            controller: _propertyAddressController,
                            decoration: new InputDecoration.collapsed(
                              hintText: "Property Address",
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            validator: (val) => val.toString().isNotEmpty
                                ? null
                                : 'Property address is a required field',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 2),
                        child: Text(
                            "Click on the GPS button for accurate location"),
                      ),
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
                                    onConfirm:
                                        (DateTime dateTime, List<int> temp) {
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    Icon(Icons.access_time,
                                        color: Colors.grey[600])
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
                                    onConfirm:
                                        (DateTime dateTime, List<int> temp) {
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    Icon(Icons.access_time,
                                        color: Colors.grey[600])
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
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4)),
                              child: ListTile(
                                title: TextFormField(
                                  controller: _spaceController,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  decoration: new InputDecoration.collapsed(
                                    hintText: "Space",
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  validator: (val) => val.isNotEmpty
                                      ? null
                                      : 'Space is a required field',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4)),
                              child: ListTile(
                                title: TextFormField(
                                  controller: _areaController,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  decoration: new InputDecoration.collapsed(
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
                            borderSide: const BorderSide(
                                color: Colors.black, width: 0.0),
                          ),
                        ),
                        validator: (val) => val.toString().isNotEmpty
                            ? null
                            : 'Description is a requried field',
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          sectionHeader("Availability"),
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
                      SizedBox(height: 12),
                      Text(
                          "You can pick the dates for the any month in ${DateTime.now().year} when the venue is not available for booking.",
                          style: TextStyle(color: Colors.grey[600])),
                      SizedBox(
                        height: 16,
                      ),
                      Calendarro(
                          unavailableDates: [],
                          onTap: (DateTime datetime) {
                            if (!newSelectedDates.add(datetime)) {
                              newSelectedDates.remove(datetime);
                            }
                          },
                          startDate: DateUtils.getFirstDayOfMonth(
                              DateTime(DateTime.now().year, selectedMonth + 1)),
                          endDate: DateUtils.getLastDayOfMonth(
                              DateTime(DateTime.now().year, selectedMonth + 1)),
                          displayMode: DisplayMode.MONTHS,
                          selectionMode: SelectionMode.MULTI,
                          selectedDates:
                              newSelectedDates.map((DateTime datetime) {
                            return DateTime(
                              datetime.year,
                              datetime.month,
                              datetime.day,
                            );
                          }).toList()),
                      SizedBox(
                        height: 18,
                      ),
                      sectionHeader("Space Best For"),
                      SizedBox(
                        height: 18,
                      ),
                      Query(
                          options:
                              QueryOptions(documentNode: gql(getVenueTypes)),
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
                                                selectedVenueTypes
                                                    .add(venueType);
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
                                                style: TextStyle(
                                                    color: Colors.black)),
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
                        decoration: new InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          hintText: "Price/Day",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 0.0),
                          ),
                        ),
                        validator: (val) => val.toString().isNotEmpty
                            ? null
                            : 'Price is a requried field',
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
                            availableTill = await _selectDate(context);
                            setState(() {});
                          },
                          title: availableTill == null
                              ? Text("Available Till")
                              : Text(formattedDateTime(
                                  availableTill.toIso8601String())),
                        ),
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
                                            selected:
                                                selectedPerks.contains(tag),
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
                      Text("Review your information and click on update."),
                      Text(
                          "By posting, you are agreeing to the Terms & Conditions of Munasaba."),
                      Visibility(
                          visible: model.editState == EditVenueStates.SAVING,
                          child: LinearProgressIndicator()),
                      RaisedButton(
                        color: primaryColor,
                        child: Text(
                          model.editState == EditVenueStates.SAVING
                              ? "UPDATING"
                              : model.editState == EditVenueStates.SAVED
                                  ? "UPDATED"
                                  : "UPDATE",
                          style: raisedTextStyle,
                        ),
                        onPressed: () async {
                          if (model.editState == EditVenueStates.SAVING) return;
                          if (model.editState == EditVenueStates.SAVED) return;
                          if (validateFields()) {
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
                            if (Provider.of<UserBasic>(context).id.isNotEmpty) {
                              await encodeDataToUpload();
                              await model.uploadEditedAd(uploadFields);
                              if (newSelectedDates != null) {
                                await model
                                    .uploadUnAvailableDates(newSelectedDates);
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
                    ],
                  ),
                ),
              ),
            ),
          );
      }),
    );
  }

  Future encodeDataToUpload() async {
    if (_isPremium && videoService.isVideoPicked()) {
      String uploadedVideoID = await videoService.httpVideoUpload();
      uploadFields["propertyVideo"] = uploadedVideoID;
    }
    // if (!_isPremium && !videoService.isVideoPicked() && !_isVideoAd) {
    //   uploadFields["propertyVideo"] = [];
    // }
    uploadFields["title"] = "Property Title";
    uploadFields["seller"] = Provider.of<UserBasic>(context).id;
    uploadFields["featuredImage"] = primaryImageIndex;
    uploadFields["adImages"] = venueImages;
    uploadFields["venueAddress"] = _propertyAddressController.text;
    uploadFields["venueLat"] = currentLocation.latitude;
    uploadFields["title"] = _titleController.text;
    uploadFields["venueLon"] = currentLocation.longitude;
    uploadFields["area"] = int.parse(_areaController.text);

    uploadFields["accommodation"] = int.parse(_spaceController.text);
    final now = new DateTime.now();
    startTime =
        DateTime(now.year, now.month, now.day, start.hour, start.minute);
    endTime = DateTime(now.year, now.month, now.day, end.hour, end.minute);
    uploadFields["timeStart"] =
        startTime.toIso8601String().split('T').elementAt(1);
    uploadFields["timeEnd"] = endTime.toIso8601String().split('T').elementAt(1);
    uploadFields["description"] = _descriptionController.text;
    uploadFields["price"] = int.parse(_priceController.text);
    uploadFields["availableTill"] = availableTill.toUtc().toIso8601String();
    uploadFields["adStatus"] = "Active";
    uploadFields["isFeatured"] = _isPremium;
    uploadFields["perkList"] = selectedPerks.map((e) => e.id).toList();
  }

  void _runPreEditTasks(AdDetail adDetail) {
    _propertyAddressController.text = adDetail.userAd.venueAddress;
    _areaController.text = adDetail.userAd.area.toString();
    _spaceController.text = adDetail.userAd.accommodation.toString();
    _descriptionController.text = adDetail.userAd.description;
    _priceController.text = adDetail.userAd.price.toString();
    _isPremium = adDetail.userAd.isFeatured;
    _titleController.text = adDetail.userAd.title;
    _isVideoAd = adDetail.userAd.isFeatured;
    venueImages.addAll(adDetail.userAd.adImages);
    selectedVenueTypes.addAll(adDetail.userAd.venueOptions.venueTypes);
    availableTill = DateTime.parse(
        restrictFractionalSeconds(adDetail.userAd.availableTill));
    startTime = DateTime.parse(
      restrictFractionalSeconds(adDetail.userAd.timeStart),
    );
    endTime =
        DateTime.parse(restrictFractionalSeconds(adDetail.userAd.timeEnd));
    start = TimeOfDay.fromDateTime(startTime);
    end = TimeOfDay.fromDateTime(endTime);

    if (adDetail.userAd.offlineDates != null) {
      adDetail.userAd.offlineDates.forEach(
          (OfflineDates offlinedate) => newSelectedDates.add(offlinedate.date));
    }
    selectedPerks.addAll(adDetail.userAd.perkList.perks);
    Position position = Position(
        latitude: adDetail.userAd.latitude,
        longitude: adDetail.userAd.latitude);
    currentLocation = position;
  }

  Future<List<Asset>> loadAssets() async {
    List<Asset> resultList;
    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 5 - venueImages.length, enableCamera: true);
      return resultList;
    } on Exception catch (e) {
      print(e.toString());
      return <Asset>[];
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

  String monthName(int monthNumber) {
    switch (monthNumber) {
      case 0:
        return "January";
      case 1:
        return "Febuary";
      case 2:
        return "March";
      case 3:
        return "April";
      case 4:
        return "May";
      case 5:
        return "June";
      case 6:
        return "July";
      case 7:
        return "August";
      case 8:
        return "September";
      case 9:
        return "October";
      case 10:
        return "November";
      case 11:
        return "December";
      default:
        return "[Invalid Index]";
    }
  }

  bool validateFields() {
    if (_propertyAddressController.text.isEmpty ||
        _areaController.text.isEmpty ||
        _spaceController.text.isEmpty ||
        start == null ||
        end == null ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        selectedVenueTypes.isEmpty ||
        availableTill == null)
      return false;
    else
      return true;
  }
}
