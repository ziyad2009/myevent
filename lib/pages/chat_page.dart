import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:provider/provider.dart';

class ChatView extends StatefulWidget {
  final String peerName;
  final String peerImage;
  final String peerStarpiID;
  final String peerFirebaseUID;
  final String myFirebaseID;
  final String myStrapiID;
  ChatView(
      {this.peerFirebaseUID,
      this.peerName,
      this.peerImage,
      this.peerStarpiID,
      this.myFirebaseID,
      this.myStrapiID});
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  String chatroomID;
  DatabaseReference _chatroomReference;
  DatabaseReference _usersReference;
  DatabaseReference _sharedChatroom;
  bool _anchorToBottom = true;
  TextEditingController messageContentController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  bool isFirstMessage = false;
  String lastDateStr = "";

  @override
  void initState() {
    super.initState();
    chatroomID = uniqueChatroomID(widget.myFirebaseID, widget.peerFirebaseUID);
    _usersReference = FirebaseDatabase.instance.reference().child("chatrooms");
    _sharedChatroom =
        FirebaseDatabase.instance.reference().child("chat_notifications");
    _chatroomReference = FirebaseDatabase.instance
        .reference()
        .child("messages")
        .child(chatroomID);
    _chatroomReference.once().then((data) {
      if (data.value == null) isFirstMessage = true;
    });
    _usersReference.once().then((data) {
      print(data.value["peerImage"].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double yourWidth = width * 0.85;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        backgroundColor: primaryColor,
        title: Text(widget.peerName ?? "Munasaba User",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        // alignment: Alignment.topLeft,
        children: <Widget>[
          Expanded(
            child: FirebaseAnimatedList(
              defaultChild: Center(child: CircularProgressIndicator()),
              query: _chatroomReference,
              key: ValueKey<bool>(_anchorToBottom),
              controller: _scrollController,
              reverse: _anchorToBottom,
              // sort: _anchorToBottom
              //     ? (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key)
              //     : null,
              sort: (DataSnapshot a, DataSnapshot b) {
                if (_anchorToBottom)
                  return b.value['createdAt'].compareTo(a.value['createdAt']);
                else
                  return null;
              },
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: GestureDetector(
                    child: Column(
                      children: <Widget>[
                        shouldShowDivider(snapshot.value['createdAt'])
                            ? Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Divider(
                                      endIndent: 12,
                                      indent: 8,
                                      thickness: 1,
                                    ),
                                  ),
                                  Text(
                                      "${dividerStamp(snapshot.value['createdAt'])}"),
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      indent: 12,
                                      endIndent: 8,
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            snapshot.value["from"].toString() ==
                                    widget.peerFirebaseUID
                                ? CircleAvatar(
                                    radius: 12,
                                    backgroundImage: widget.peerImage != null
                                        ? NetworkImage(
                                            widget.peerImage,
                                          )
                                        : AssetImage("lib/assets/crying.png"),
                                  )
                                : Container(),
                            Tooltip(
                              message:
                                  "${formattedTimestamps(snapshot.value['createdAt'])}",
                              child: Column(
                                crossAxisAlignment: snapshot.value["from"] ==
                                        widget.myFirebaseID
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      "${snapshot.value["message"]}",
                                      style: TextStyle(
                                        color:
                                            snapshot.value["from"].toString() ==
                                                    widget.myFirebaseID
                                                ? Colors.white
                                                : Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    padding: EdgeInsets.fromLTRB(
                                        15.0, 10.0, 15.0, 10.0),
                                    width: 160.0,
                                    decoration: BoxDecoration(
                                      color:
                                          snapshot.value["from"].toString() ==
                                                  widget.myFirebaseID
                                              ? primaryColor
                                              : Color(0x2A7F0A3D),
                                      borderRadius: snapshot.value["from"]
                                                  .toString() ==
                                              widget.myFirebaseID
                                          ? BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            ) // The chat bubble for me
                                          : BorderRadius.only(
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            ), // The chat bubble for peer
                                    ),
                                    margin: EdgeInsets.only(
                                      right:
                                          snapshot.value["from"].toString() ==
                                                  widget.myFirebaseID
                                              ? 0
                                              : 150,
                                      left: snapshot.value["from"].toString() ==
                                              widget.myFirebaseID
                                          ? 150
                                          : 5,
                                      bottom: 8.0,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                        "${formattedTimestamps(snapshot.value['createdAt'])}",
                                        style:
                                            TextStyle(fontSize: 10, height: 1)),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    onDoubleTap: () {
                      // if (snapshot.value["from"] == widget.myFirebaseID) {
                      //   FirebaseDatabase.instance
                      //       .reference()
                      //       .child("messages")
                      //       .child(chatroomID)
                      //       .child(snapshot.key)
                      //       .remove();
                      //   Fluttertoast.showToast(
                      //       msg: "Deleted",
                      //       gravity: ToastGravity.CENTER,
                      //       toastLength: Toast.LENGTH_SHORT);
                      // }
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: yourWidth,
                  padding: EdgeInsets.only(left: 6.0),
                  child: TextField(
                    controller: messageContentController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    decoration: InputDecoration.collapsed(
                        hintText: "Type your message",
                        hintStyle: TextStyle(fontWeight: FontWeight.w500),
                        border: InputBorder.none),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: primaryColor,
                  onPressed: () {
                    print(widget.peerStarpiID);
                    print(widget.myFirebaseID);
                    if (widget.peerFirebaseUID == null ||
                        widget.myFirebaseID == null) {
                      Fluttertoast.showToast(
                          msg:
                              "Sorry! You can not start a converation with this user",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIos: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      return;
                    }
                    if (messageContentController.text.isNotEmpty) {
                      if (isFirstMessage) {
                        _usersReference = FirebaseDatabase.instance
                            .reference()
                            .child("chatrooms");
                        // Creating a new chatroom for for current user
                        _usersReference
                            .child(widget.myFirebaseID)
                            .child(chatroomID)
                            .set(<String, dynamic>{
                          "cid": chatroomID,
                          "createdBy": widget.myFirebaseID,
                          "activity": ServerValue.timestamp,
                          "deleted": false,
                          "deletedAt": 0,
                          "peerName": widget.peerName,
                          "peerImage": widget.peerImage,
                          "activityBy":
                              Provider.of<UserBasic>(context).firebaseID
                        });
                        // Creating the new chatroom for the peer user
                        _usersReference
                            .child(widget.peerFirebaseUID)
                            .child(chatroomID)
                            .set(<String, dynamic>{
                          "cid": chatroomID,
                          "createdBy": widget.myFirebaseID,
                          "activity": ServerValue.timestamp,
                          "peerName": Provider.of<UserBasic>(context).fullName,
                          "deleted": false,
                          "deletedAt": 0,
                          "peerImage": Provider.of<UserBasic>(context)
                                  ?.profilePicture
                                  ?.url ??
                              "https://picsum.photos/200",
                          "activityBy":
                              Provider.of<UserBasic>(context).firebaseID
                        });
                        // Create a shared chatroom with Strapi IDs for FCM
                        _sharedChatroom.child(chatroomID).set(<String, dynamic>{
                          "peer1": Provider.of<UserBasic>(context).id,
                          "peer2": widget.peerStarpiID,
                          "lastActivityBy": Provider.of<UserBasic>(context).id,
                          "peer1Name": Provider.of<UserBasic>(context).fullName,
                          "peer2Name": widget.peerName
                        });
                        // Chatrooms were created now set the isFirstMessage to false
                        isFirstMessage = false;
                      }
                      _chatroomReference.push().set(<String, dynamic>{
                        "createdAt": ServerValue.timestamp,
                        "from": widget.myFirebaseID,
                        "to": widget.peerFirebaseUID,
                        "message": messageContentController.text
                      });
                      // Updating the activity of the chatroom for both users
                      _usersReference // For the app user
                          .child(widget.myFirebaseID)
                          .child(chatroomID)
                          .child("activity")
                          .set(ServerValue.timestamp);
                      _usersReference // For the app user
                          .child(widget.myFirebaseID)
                          .child(chatroomID)
                          .child("activityBy")
                          .set(Provider.of<UserBasic>(context).firebaseID);
                      _usersReference // For the external user
                          .child(widget.peerFirebaseUID)
                          .child(chatroomID)
                          .child("activity")
                          .set(ServerValue.timestamp);
                      _usersReference // For the external user
                          .child(widget.peerFirebaseUID)
                          .child(chatroomID)
                          .child("activityBy")
                          .set(Provider.of<UserBasic>(context).firebaseID);
                      // Updating the shared chatroom lastActivityBy for both users to send notifications via cloud functions
                      _sharedChatroom
                          .child(chatroomID)
                          .child("lastActivityBy")
                          .set(Provider.of<UserBasic>(context).id);
                      setState(() {
                        messageContentController.clear();
                      });
                      // SchedulerBinding.instance.addPostFrameCallback((_) {
                      //   _scrollController.animateTo(
                      //     _scrollController.position.maxScrollExtent,
                      //     duration: const Duration(milliseconds: 500),
                      //     curve: Curves.easeOut,
                      //   );
                      // });
                    } else
                      Fluttertoast.showToast(
                          msg:
                              "An error occured while sending the message try again later!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIos: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String uniqueChatroomID(String currentId, String peerId) {
    int compare = currentId.compareTo(peerId);
    if (compare > 0)
      return "$currentId-$peerId";
    else
      return "$peerId-$currentId";
  }
  // DateTime parseTime(dynamic date) {
  //   return Platform.isIOS ? (date as Timestamp).toDate() : (date as DateTime);
  // }

  String formattedTimestamps(dynamic timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formatedDateTime =
        DateFormat("EEE, MMM d, h:mm a").format(dateTime).toString();
    return formatedDateTime;
  }

  // bool shouldShowDivider(dynamic timestamp) {
  //   DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  //   if (dateTime.difference(lastDateTime).inDays > 0) {
  //     lastDateTime = dateTime;
  //     return true;
  //   } else
  //     return false;
  // }

  bool shouldShowDivider(dynamic timestamp) {
    if (dividerStamp(timestamp) != lastDateStr) {
      lastDateStr = dividerStamp(timestamp);
      return true;
    } else
      return false;
  }

  String dividerStamp(dynamic timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat("EEE MMM d, yy").format(dateTime).toString();
  }
}
