import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/pages/ad_upload_form.dart';
import 'package:myevents/pages/directory_page.dart';
import 'package:myevents/pages/saved.dart';
import 'package:myevents/pages/trending_page.dart';
import 'package:myevents/service_addons/addons_grid.dart';
import 'package:myevents/service_addons/upload_service_page.dart';

class FrontHome extends StatefulWidget {
  @override
  _FrontHomeNaiveState createState() => _FrontHomeNaiveState();
}

class _FrontHomeNaiveState extends State<FrontHome> {
  int _selectedIndex = 0;
  bool enableSlideOff = true;
  bool hideCloseButton = false;
  bool onlyOne = true;
  bool crossPage = true;
  int seconds = 7;
  int animationMilliseconds = 300;
  int animationReverseMilliseconds = 300;

  final FirebaseMessaging _fcm = FirebaseMessaging();

  void _onItemTapped(int selected) {
    setState(() {
      _selectedIndex = selected;
    });
  }

  Widget _loadCurrentWidget() {
    if (_selectedIndex == 0)
      return TrendingPage();
    else if (_selectedIndex == 1)
      return DirectoryPage();
    else if (_selectedIndex == 2)
      return AddonsGrid();
    else
      return SavedPage();
  }

  @override
  void initState() {
    super.initState();

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
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
            onLongPress: () {},
            onlyOne: onlyOne,
            crossPage: crossPage,
            animationDuration: Duration(milliseconds: animationMilliseconds),
            animationReverseDuration:
                Duration(milliseconds: animationReverseMilliseconds),
            duration: Duration(seconds: seconds));
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loadCurrentWidget(),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primaryColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showUnselectedLabels: false,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
          BottomNavigationBarItem(
              icon: Icon(Icons.business), title: Text("Venues")),
          BottomNavigationBarItem(
              icon: Icon(Icons.widgets), title: Text("Services")),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), title: Text("Saved"))
        ],
      ),
      floatingActionButton: Visibility(
        visible: _selectedIndex != 3,
        child: SpeedDial(
          marginRight: 18,
          marginBottom: 20,
          animatedIcon: AnimatedIcons.add_event,
          animatedIconTheme: IconThemeData(size: 24.0, color: Colors.white),
          closeManually: false,
          curve: Curves.bounceIn,
          overlayColor: primaryColor,
          overlayOpacity: 0.3,
          tooltip: 'Speed Dial',
          heroTag: 'speed-dial-hero-tag',
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          children: [
            SpeedDialChild(
                child: Icon(Icons.business, color: Colors.white),
                backgroundColor: primaryColor,
                label: 'Upload Event Space',
                labelBackgroundColor: Colors.white,
                labelStyle: TextStyle(fontSize: 18.0, color: primaryColor),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadAdForm(),
                    ),
                  );
                }),
            SpeedDialChild(
              child: Icon(Icons.widgets, color: Colors.white),
              backgroundColor: primaryColor,
              label: 'Upload Service',
              labelBackgroundColor: Colors.white,
              labelStyle: TextStyle(fontSize: 18.0, color: primaryColor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadServiceForm(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
