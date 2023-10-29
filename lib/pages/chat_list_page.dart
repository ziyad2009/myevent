import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/pages/chat_page.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/widgets/confirm_dialog.dart';
import 'package:myevents/widgets/report_dialog.dart';
import 'package:provider/provider.dart';

enum ChatListActions { Report, Delete }

class ChatList extends StatefulWidget {
  final String userFirebaseID;

  const ChatList({Key key, this.userFirebaseID}) : super(key: key);
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  bool _anchorToBottom = false;
  int lastAcitivity;
  BackendService backendService = locator<BackendService>();
  bool isListEmpty = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      if (user != null) {
        print(user.uid);
        FirebaseDatabase.instance
            .reference()
            .child("chatrooms")
            .child(user.uid)
            .orderByChild("deleted")
            .equalTo(false)
            .once()
            .then((DataSnapshot snapshot) {
          if (snapshot.value == null)
            setState(() {
              isListEmpty = true;
            });
        });
      }
    });
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment:
              isListEmpty ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: <Widget>[
            Provider.of<UserBasic>(context).id.isNotEmpty
                ? isListEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.chat_bubble_outline,
                              color: primaryColor, size: 36),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "You do not have any active conversations",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Flexible(
                        child: FirebaseAnimatedList(
                          defaultChild:
                              Center(child: CircularProgressIndicator()),
                          query: FirebaseDatabase.instance
                              .reference()
                              .child("chatrooms")
                              .child(Provider.of<UserBasic>(context).firebaseID)
                              .orderByChild("deleted")
                              .equalTo(false),
                          key: ValueKey<bool>(_anchorToBottom),
                          reverse: _anchorToBottom,
                          sort: (DataSnapshot a, DataSnapshot b) {
                            return b.value["activity"]
                                .compareTo(a.value["activity"]);
                          },
                          itemBuilder: (BuildContext context,
                              DataSnapshot snapshot,
                              Animation<double> animation,
                              int index) {
                            return SizeTransition(
                              sizeFactor: animation,
                              child: InkWell(
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            snapshot.value["peerImage"] != null
                                                ? NetworkImage(
                                                    snapshot.value["peerImage"],
                                                  )
                                                : AssetImage(
                                                    "lib/assets/crying.png"),
                                      ),
                                      title: Text(
                                        '${snapshot.value["peerName"]}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      subtitle: Text(
                                        "Last activity: " +
                                            formattedTimestamps(
                                                snapshot.value["activity"]),
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      onTap: () {
                                        String cid =
                                            snapshot.value["cid"].toString();
                                        List<String> peerInChatroom =
                                            cid.split("-");
                                        print(peerInChatroom);
                                        print(peerInChatroom.singleWhere(
                                            (String s) =>
                                                s !=
                                                Provider.of<UserBasic>(context)
                                                    .firebaseID));
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatView(
                                              peerName: snapshot
                                                  .value["peerName"]
                                                  .toString(),
                                              peerImage:
                                                  snapshot.value["peerImage"],
                                              peerFirebaseUID: peerInChatroom
                                                  .singleWhere((String s) =>
                                                      s !=
                                                      Provider.of<UserBasic>(
                                                              context)
                                                          .firebaseID)
                                                  .trim(),
                                              myFirebaseID:
                                                  Provider.of<UserBasic>(
                                                          context)
                                                      .firebaseID,
                                              myStrapiID:
                                                  Provider.of<UserBasic>(
                                                          context,
                                                          listen: false)
                                                      .id,
                                            ),
                                          ),
                                        ).then((_) {
                                          FirebaseDatabase.instance
                                              .reference()
                                              .child("chatrooms")
                                              .child(Provider.of<UserBasic>(
                                                      context)
                                                  .firebaseID)
                                              .child(cid)
                                              .child(Provider.of<UserBasic>(
                                                      context)
                                                  .firebaseID)
                                              .set(ServerValue.timestamp);
                                        });
                                      },
                                      trailing: PopupMenuButton(
                                        onSelected:
                                            (ChatListActions action) async {
                                          if (action ==
                                              ChatListActions.Delete) {
                                            showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    DeleteConfirmationDialog(
                                                      dialogTitle:
                                                          "Delete Chat?",
                                                      deleteContent:
                                                          "Are you sure you want to delete conversation with this user?\n\nOnce deleted this chat cannot be recoved.",
                                                      yesButton: "Delete",
                                                      noButton: "Cancel",
                                                    )).then((bool value) {
                                              if (value) {
                                                snapshot.value["deleted"] =
                                                    true;
                                                snapshot.value["deletedAt"] =
                                                    ServerValue.timestamp;
                                                FirebaseDatabase.instance
                                                    .reference()
                                                    .child("chatrooms")
                                                  .child(
                                                        Provider.of<UserBasic>(
                                                                context)
                                                            .firebaseID)
                                                    .child(
                                                        snapshot.value["cid"])
                                                    .update(new Map<String,
                                                            dynamic>.from(
                                                        snapshot.value));
                                                Fluttertoast.showToast(
                                                    msg: "Chat deleted",
                                                    textColor: Colors.white,
                                                    backgroundColor:
                                                        Color(0xFFE2A500),
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    toastLength:
                                                        Toast.LENGTH_LONG);
                                              }
                                            });
                                          } else if (action ==
                                              ChatListActions.Report) {
                                            showDialog<bool>(
                                              context: context,
                                              builder: (context) =>
                                                  ReportDialog(
                                                fields: <String, String>{
                                                  "chatroom":
                                                      snapshot.value["cid"],
                                                  "report_type": "chat"
                                                },
                                              ),
                                            ).then((bool value) {
                                              if (value)
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Thank you for reporting! We'll look into this as soon as possible.",
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    toastLength:
                                                        Toast.LENGTH_LONG);
                                            });
                                          }
                                        },
                                        child: Icon(Icons.more_vert),
                                        itemBuilder: (context) =>
                                            <PopupMenuEntry<ChatListActions>>[
                                          PopupMenuItem(
                                            value: ChatListActions.Delete,
                                            child: Text("Delete Chat"),
                                          ),
                                          PopupMenuItem(
                                            value: ChatListActions.Report,
                                            child: Text("Report Chat"),
                                            enabled:
                                                Provider.of<UserBasic>(context)
                                                    .id
                                                    .isNotEmpty,
                                          )
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      indent: 72,
                                      thickness: 1,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                : Expanded(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          "You need an account to start conversations with other people",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  String formattedTimestamps(dynamic timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formatedDateTime =
        DateFormat("EEE, MMM d, h:mm a").format(dateTime).toString();
    return formatedDateTime;
  }
}
