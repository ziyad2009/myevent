import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/backend/filters_service.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/pages/booking_pages/my_bookings.dart';
import 'package:myevents/pages/booking_pages/my_requests.dart';
import 'package:myevents/pages/chat_list_page.dart';
import 'package:myevents/pages/front_page_one_naive.dart';
import 'package:myevents/pages/phone_sign_in.dart';
import 'package:myevents/pages/profile_page.dart';
import 'package:myevents/pages/signup.dart';
import 'package:myevents/pages/support_page.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:provider/provider.dart';

enum FrontPages { HomeSimple, Chats, HelpSupport, Logout, MyBookings, Requests }
enum BackPages { Navigation, Filters }

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _BackdropPageState createState() => new _BackdropPageState();
}

class _BackdropPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // static const _PANEL_HEADER_HEIGHT = 130.0;

  FrontPages frontPages = FrontPages.HomeSimple;
  BackPages backPages = BackPages.Navigation;

  final BackendService _backendService = locator<BackendService>();
  final FilterService _filterService = locator<FilterService>();

  AnimationController _controller;
  TextEditingController _propertyAddressController = TextEditingController();
  TextEditingController _areaController = TextEditingController();
  TextEditingController _spaceController = TextEditingController();
  bool _filterPerks = false;

  Filter appliedFilter = Filter();

  int chatCounter = 0;
  int notificationCounter = 0;

  bool enableSlideOff = true;
  bool hideCloseButton = false;
  bool onlyOne = true;
  bool crossPage = true;
  int seconds = 7;
  int animationMilliseconds = 300;
  int animationReverseMilliseconds = 300;

  final FirebaseMessaging _fcm = FirebaseMessaging();

  TimeOfDay start;
  TimeOfDay end;
  DateTime startTime;
  DateTime endTime;

  String startTimeStr;
  String endTimeStr;

  bool get _isPanelVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        duration: const Duration(milliseconds: 100), value: 1.0, vsync: this);
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      if (user != null) {
        FirebaseDatabase.instance
            .reference()
            .child("chatrooms")
            .child(user.uid)
            .onValue
            .listen((Event e) {
          int counter = chatCounter;
          if (e.snapshot.value != null) {
            Map<dynamic, dynamic> collection = e.snapshot.value;
            collection.forEach((dynamic chatroomID, dynamic chatroomData) {
              Map<dynamic, dynamic> inner = chatroomData;
              if (inner["activity"] > inner[user.uid]) chatCounter++;
            });
          }
          if (chatCounter != counter) setState(() {});
        });
      }
    });
    _fcm.requestNotificationPermissions();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (Platform.isIOS) {
          setState(() {});
          BotToast.showNotification(
              leading: (_) => SizedBox(
                    height: 40,
                    width: 40,
                    child: ClipOval(
                      child: message["type"] == "message"
                          ? Icon(
                              Icons.chat,
                              color: primaryColor,
                            )
                          : Icon(
                              Icons.notifications_active,
                              color: primaryColor,
                            ),
                    ),
                  ),
              title: (_) => Text(message['aps']['alert']['title']),
              subtitle: (_) => Text(message['aps']['alert']['body']),
              enableSlideOff: enableSlideOff,
              onTap: () {},
              onlyOne: onlyOne,
              crossPage: crossPage,
              animationDuration: Duration(milliseconds: animationMilliseconds),
              animationReverseDuration:
                  Duration(milliseconds: animationReverseMilliseconds),
              duration: Duration(seconds: seconds));
        } else {
          setState(() {});
          BotToast.showNotification(
              leading: (_) => SizedBox(
                    height: 40,
                    width: 40,
                    child: ClipOval(
                      child: message["data"]["type"] == "message"
                          ? Icon(
                              Icons.chat,
                              color: primaryColor,
                            )
                          : Icon(
                              Icons.notifications_active,
                              color: primaryColor,
                            ),
                    ),
                  ),
              title: (_) => Text(message['notification']['title']),
              subtitle: (_) => Text(message['notification']['body']),
              enableSlideOff: enableSlideOff,
              onTap: () {},
              onlyOne: onlyOne,
              crossPage: crossPage,
              animationDuration: Duration(milliseconds: animationMilliseconds),
              animationReverseDuration:
                  Duration(milliseconds: animationReverseMilliseconds),
              duration: Duration(seconds: seconds));
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Animation<RelativeRect> _getPanelAnimation(BoxConstraints constraints) {
    final double height = constraints.biggest.height;
    double top = height - (backPages == BackPages.Navigation ? 230.0 : 130.0);
    double bottom = -(backPages == BackPages.Navigation ? 130.0 : 2530.0);
    return new RelativeRectTween(
      begin: new RelativeRect.fromLTRB(0.0, top, 0.0, bottom),
      end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(new CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final Animation<RelativeRect> animation = _getPanelAnimation(constraints);
    final ThemeData theme = Theme.of(context);
    return new Container(
      color: theme.primaryColor,
      child: new Stack(
        children: <Widget>[
          Center(
            child: backPages == BackPages.Navigation
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      FlatButton(
                        child: new Text(
                          "Home",
                          style: backdropListStyle,
                        ),
                        onPressed: () {
                          setState(() {
                            frontPages = FrontPages.HomeSimple;
                          });
                          _controller.fling(
                              velocity: _isPanelVisible ? -1.0 : 1.0);
                        },
                      ),
                      FlatButton(
                        child: new Text(
                          "My Bookings",
                          style: backdropListStyle,
                        ),
                        onPressed: () {
                          setState(() {
                            frontPages = FrontPages.MyBookings;
                          });
                          _controller.fling(
                              velocity: _isPanelVisible ? -1.0 : 1.0);
                        },
                      ),
                      FlatButton(
                        child: new Text(
                          "Requests",
                          style: backdropListStyle,
                        ),
                        onPressed: () {
                          setState(() {
                            frontPages = FrontPages.Requests;
                          });
                          _controller.fling(
                              velocity: _isPanelVisible ? -1.0 : 1.0);
                        },
                      ),
                      FlatButton(
                        child: new Text(
                          "Chats ($chatCounter Unread)",
                          // "Chats (${chatCounter > 0 ? "NEW" : ""})",
                          // "Chats",
                          style: backdropListStyle,
                        ),
                        onPressed: () {
                          setState(() {
                            frontPages = FrontPages.Chats;
                          });
                          _controller.fling(
                              velocity: _isPanelVisible ? -1.0 : 1.0);
                        },
                      ),
                      FlatButton(
                        child: new Text(
                          "Help & Support",
                          style: backdropListStyle,
                        ),
                        onPressed: () {
                          setState(() {
                            frontPages = FrontPages.HelpSupport;
                          });
                          _controller.fling(
                              velocity: _isPanelVisible ? -1.0 : 1.0);
                        },
                      ),
                      FlatButton(
                        child: new Text(
                          "Logout",
                          style: backdropListStyle,
                        ),
                        onPressed: () async {
                          await _backendService.savePrefrences("token", null);
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PhoneSignIn()));
                        },
                      ),
                    ],
                  )
                : Container(
                    padding: EdgeInsets.only(left: 32, right: 32, bottom: 16),
                    child: _filterWidgets()),
          ),
          new PositionedTransition(
            rect: animation,
            child: new Material(
                borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(8.0),
                    topRight: const Radius.circular(8.0)),
                elevation: 12.0,
                child: _returnFrontPage()),
          ),
        ],
      ),
    );
  }

  Widget _returnFrontPage() {
    if (frontPages == FrontPages.HomeSimple)
      return FrontHome();
    else if (frontPages == FrontPages.Chats)
      return ChatList();
    else if (frontPages == FrontPages.HelpSupport)
      return SupportPage();
    else if (frontPages == FrontPages.MyBookings)
      return MyBookingsPage();
    else if (frontPages == FrontPages.Requests)
      return MyRequestsPage();
    else
      return Container();
  }

  Widget _filterWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(4)),
            child: ListTile(
              trailing: Icon(Icons.place, color: Colors.white),
              title: TextField(
                style: TextStyle(color: Colors.white),
                controller: _propertyAddressController,
                decoration: new InputDecoration.collapsed(
                  hintText: "Location",
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(4)),
          child: ListTile(
            trailing: Icon(Icons.business, color: Colors.white),
            title: TextField(
              style: TextStyle(color: Colors.white),
              controller: _areaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: new InputDecoration.collapsed(
                hintText: "Area",
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(4)),
          child: ListTile(
            trailing: Icon(Icons.people, color: Colors.white),
            title: TextField(
              style: TextStyle(color: Colors.white),
              controller: _spaceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: new InputDecoration.collapsed(
                hintText: "Accomodation",
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  DatePicker.showDatePicker(context,
                      pickerMode: DateTimePickerMode.time,
                      initialDateTime: startTime ?? DateTime.now(),
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
                      border: Border.all(color: Colors.white),
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
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Icon(Icons.access_time, color: Colors.white)
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
                      initialDateTime: endTime ?? DateTime.now(),
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
                      border: Border.all(color: Colors.white),
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
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Icon(Icons.access_time, color: Colors.white)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // GestureDetector(
        //   child: Container(
        //     decoration: BoxDecoration(
        //         border: Border.all(color: Colors.white),
        //         borderRadius: BorderRadius.circular(4)),
        //     child: ListTile(
        //       trailing: Icon(Icons.access_time, color: Colors.white),
        //       title: Text(
        //           "${start?.format(context)?.toString() ?? "Start Time"} - ${end?.format(context)?.toString() ?? "End Time"}",
        //           style: TextStyle(color: Colors.white)),
        //     ),
        //   ),
        //   onTap: () {
        //     // Open a dialogue to pick from and to time i.e Time Picker
        //     showDialog(
        //         context: context,
        //         builder: (context) =>
        //             Dialog(child: _selectTimeDialog(context)));
        //   },
        // ),
        // SizedBox(height: 8),
        // Container(
        //   decoration: BoxDecoration(
        //       border: Border.all(color: Colors.white),
        //       borderRadius: BorderRadius.circular(4)),
        //   child: ListTile(
        //     trailing: Theme(
        //       data: ThemeData(unselectedWidgetColor: Colors.white),
        //       child: Checkbox(
        //         checkColor: primaryColor,
        //         activeColor: Colors.white,
        //         value: _filterPerks,
        //         onChanged: (bool perksCheck) {
        //           setState(() {
        //             _filterPerks = perksCheck;
        //           });
        //         },
        //       ),
        //     ),
        //     title: Text("Include Perks", style: TextStyle(color: Colors.white)),
        //   ),
        // ),
        SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text("APPLY", style: TextStyle(color: primaryColor)),
              color: Colors.white,
              onPressed: () {
                if (startTime != null) {
                  startTimeStr =
                      startTime.toIso8601String().split('T').elementAt(1);
                }
                if (endTime != null) {
                  endTimeStr =
                      endTime.toIso8601String().split('T').elementAt(1);
                }
                Map<String, dynamic> filterVals = {
                  "venueAddress": _propertyAddressController.text,
                  "timeStart_gte": startTimeStr ?? null,
                  "timeEnd_lte": endTimeStr ?? null,
                  "area_gte": int.tryParse(_areaController.text.trim()),
                  "accommodation_gte": int.tryParse(_spaceController.text),
                  // "perkList": !_filterPerks
                };
                filterVals.removeWhere((String key, dynamic val) {
                  return val == null;
                });
                if (filterVals["venueAddress"].isEmpty)
                  filterVals.remove("venueAddress");

                Filter filter = Filter(filterValues: {
                  // "sort": _sortDecending ? "price:asc" : "price:desc",
                  "field": filterVals
                }, priceSortDecending: false);
                // Broadcasting  the filters so that DirectoryPage can use and apply them
                appliedFilter = filter;
                _filterService.filterController.add(appliedFilter);
                _controller.fling(velocity: _isPanelVisible ? -1.0 : 1.0);
              },
            ),
            OutlineButton(
              borderSide: BorderSide(color: Colors.grey),
              child: Text("CLEAR", style: TextStyle(color: Colors.white)),
              color: Colors.white,
              onPressed: () {
                // Nulling the filters
                _filterService.filterController.add(Filter(filterValues: {
                  // "sort": _sortDecending ? "price:asc" : "price:desc",
                  "field": {}
                }, priceSortDecending: false));
                _controller.fling(velocity: _isPanelVisible ? -1.0 : 1.0);
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        title: _appBarTitle(),
        elevation: 0.0,
        leading: new IconButton(
          onPressed: () {
            backPages = BackPages.Navigation;
            _controller.fling(velocity: _isPanelVisible ? -1.0 : 1.0);
          },
          icon: new AnimatedIcon(
            icon: AnimatedIcons.close_menu,
            progress: _controller.view,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                          userID: Provider.of<UserBasic>(context).id)));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              backPages = BackPages.Filters;
              _controller.fling(velocity: _isPanelVisible ? -1.0 : 1.0);
            },
          )
        ],
      ),
      body: new LayoutBuilder(
        builder: _buildStack,
      ),
    );
  }

  Widget _appBarTitle() {
    if (frontPages == FrontPages.MyBookings)
      return Text("My Bookings", style: TextStyle(color: Colors.white));
    else if (frontPages == FrontPages.Requests)
      return Text("My Requests", style: TextStyle(color: Colors.white));
    else if (frontPages == FrontPages.HelpSupport)
      return Text("Help & support", style: TextStyle(color: Colors.white));
    else if (frontPages == FrontPages.Chats)
      return Text("Chats", style: TextStyle(color: Colors.white));
    else
      return Container();
  }
}
