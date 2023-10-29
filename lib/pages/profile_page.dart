import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_search/material_search.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/common/custom_animation.dart';
import 'package:myevents/common/sliver_info_delegate.dart';
import 'package:myevents/models/ad_dir_model.dart';
import 'package:myevents/models/profile_model.dart';
import 'package:myevents/pages/ad_upload_form.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pages/chat_page.dart';
import 'package:myevents/pages/edit_profile.dart';
import 'package:myevents/pages/image_view.dart';
import 'package:myevents/pages/single_page.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/pojos/user_detail.dart';
import 'package:myevents/service_addons/addon_detail_page.dart';
import 'package:myevents/viewstate.dart';
import 'package:myevents/widgets/confirm_dialog.dart';
import 'package:myevents/widgets/property_card.dart';
import 'package:myevents/widgets/service_card.dart';
import 'package:myevents/widgets/shimmer_effect.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  final String userID;
  ProfilePage({this.userID});
  List<Asset> _pickedImages = [];
  List<String> selectedAds = [];

  @override
  Widget build(BuildContext context) {
    return BaseView<ProfileModel>(
      onModelReady: (model) async {
        model.externalUser = userID != Provider.of<UserBasic>(context).id;
        await model.loadProfile(userID);
      },
      builder: (context, model, child) => model.state == ViewState.Busy
          ? Material(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    "Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context)),
                ),
                body: Center(child: CircularProgressIndicator()),
              ),
            )
          : Material(
              child: Scaffold(
                body: DefaultTabController(
                  length: 3,
                  child: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxSelected) {
                      return <Widget>[
                        SliverAppBar(
                            titleSpacing: 0.0,
                            leading: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            actions: <Widget>[
                              /* Searching is only allowed in user's own personal profile */
                              Visibility(
                                visible: Provider.of<UserBasic>(context,
                                            listen: false)
                                        .id ==
                                    model.userDetail.user.id,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push<String>(
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (context) =>
                                            MaterialSearch<UserBasic>(
                                          placeholder: "Search Users",
                                          getResults: (String criteria) async {
                                            UserSearchList userSearchList =
                                                await model
                                                    .searchUsers(criteria);
                                            return userSearchList.users
                                                .map((UserBasic user) =>
                                                    new MaterialSearchResult<
                                                            UserBasic>(
                                                        value: user,
                                                        text: user.fullName,
                                                        icon: Icons
                                                            .person_outline))
                                                .toList();
                                          },
                                          filter:
                                              (dynamic value, String criteria) {
                                            return value.fullName
                                                .toLowerCase()
                                                .trim()
                                                .contains(new RegExp(r'' +
                                                    criteria
                                                        .toLowerCase()
                                                        .trim() +
                                                    ''));
                                          },
                                          onSelect: (dynamic value) {
                                            print("Selected User " +
                                                value.fullName);
                                            Navigator.pop(context, value.id);
                                          },
                                        ),
                                      ),
                                    )
                                        .then((String userIdToLoad) {
                                      if (userIdToLoad.isNotEmpty &&
                                          userIdToLoad != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfilePage(
                                                userID: userIdToLoad),
                                          ),
                                        );
                                      }
                                    });
                                  },
                                ),
                              )
                            ],
                            expandedHeight: 130,
                            floating: false,
                            pinned: true,
                            flexibleSpace: FlexibleSpaceBar(
                              centerTitle: false,
                              background: GestureDetector(
                                onLongPress: () async {
                                  if (model.externalUser) return;
                                  if (await checkAndRequestSoragePermissions()) {
                                    showDialog<bool>(
                                      context: context,
                                      builder: (context) =>
                                          DeleteConfirmationDialog(
                                        dialogTitle: "Cover Image",
                                        deleteContent:
                                            "What would you like to do?",
                                        noButton: "Change Cover Image",
                                        yesButton: "Remove Cover Image",
                                      ),
                                    ).then((bool value) async {
                                      if (!value)
                                        _pickedImages = await loadAssets(1);
                                      if (_pickedImages.isNotEmpty) {
                                        BotToast.showText(
                                          text: 'Updating your cover photo..',
                                          wrapToastAnimation: (controller,
                                                  cancel, Widget child) =>
                                              CustomAnimationWidget(
                                            controller: controller,
                                            child: child,
                                          ),
                                        );
                                        await model.uploadImage(
                                            _pickedImages, "coverImage");
                                        _pickedImages.clear();
                                      }
                                    });
                                  }
                                },
                                child: model.userDetail.user.coverImage != null
                                    ? Image.network(
                                        model.userDetail.user.coverImage.url,
                                        fit: BoxFit.cover,
                                      )
                                    : Provider.of<UserBasic>(context,
                                                    listen: false)
                                                .id ==
                                            model.userDetail.user.id
                                        ? Container(
                                            padding: EdgeInsets.only(
                                                top: 32, left: 24, right: 24),
                                            height: 130,
                                            color: primaryColor,
                                            child: Center(
                                              child: Text(
                                                "Long press to change your cover image or your profile picture.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            padding: EdgeInsets.only(
                                                top: 32, left: 24, right: 24),
                                            height: 130,
                                            color: primaryColor,
                                            child: Center(
                                              child: Text(
                                                "This seller did not provide a cover photo!",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                              ),
                            )),
                        SliverPersistentHeader(
                          delegate: SliverUserProfileInfoDelegate(
                            minHeight: 75,
                            maxHeight: 75,
                            userInfoHeader: Container(
                              padding: EdgeInsets.only(left: 4, right: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  GestureDetector(
                                    onLongPress: () async {
                                      if (model.externalUser) return;
                                      if (await checkAndRequestSoragePermissions()) {
                                        showDialog<bool>(
                                          context: context,
                                          builder: (context) =>
                                              DeleteConfirmationDialog(
                                            dialogTitle: "Profile Image",
                                            deleteContent:
                                                "What would you like to do?",
                                            noButton: "Change Profile Image",
                                            yesButton: "Remove Profile Image",
                                          ),
                                        ).then((bool value) async {
                                          if (!value)
                                            _pickedImages = await loadAssets(1);
                                          if (_pickedImages.isNotEmpty) {
                                            BotToast.showText(
                                              text:
                                                  'Updating your profile photo..',
                                              wrapToastAnimation: (controller,
                                                      cancel, Widget child) =>
                                                  CustomAnimationWidget(
                                                controller: controller,
                                                child: child,
                                              ),
                                            );
                                            await model.uploadImage(
                                                _pickedImages,
                                                "profilePicture");
                                            _pickedImages.clear();
                                          }
                                        });
                                      }
                                    },
                                    onTap: () {
                                      if (model.userDetail.user.profilePicture
                                              .url !=
                                          null)
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ImageView(
                                              imagesList: List.generate(
                                                  1,
                                                  (int index) => model
                                                      .userDetail
                                                      .user
                                                      .profilePicture),
                                              startPosition: 0,
                                            ),
                                          ),
                                        );
                                    },
                                    child: CircleAvatar(
                                      backgroundImage: model.userDetail.user
                                                  .profilePicture !=
                                              null
                                          ? NetworkImage(
                                              model.userDetail.user
                                                  .profilePicture.url,
                                            )
                                          : AssetImage("lib/assets/crying.png"),
                                      backgroundColor: Colors.transparent,
                                      maxRadius: 30,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 8.0, right: 8.0, top: 12.0),
                                          child: Flexible(
                                            child: Text(
                                              model.userDetail.user.fullName ??
                                                  "Munasaba User",
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  color: Color(0x99000000)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Flexible(
                                          child: Text(
                                            model.userDetail.user.shortBio ??
                                                "No bio added",
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Color(0x99000000)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 25),
                              Expanded(
                                child: model.externalUser
                                    ? RaisedButton(
                                        color: primaryColor,
                                        child: Text(
                                          "CHAT",
                                          style: raisedTextStyle,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatView(
                                                  myFirebaseID:
                                                      Provider.of<UserBasic>(
                                                              context)
                                                          .firebaseID,
                                                  peerFirebaseUID: model
                                                      .userDetail
                                                      .user
                                                      .firebaseID,
                                                  peerStarpiID:
                                                      model.userDetail.user.id,
                                                  peerName: model
                                                      .userDetail.user.fullName,
                                                  peerImage: model
                                                          ?.userDetail
                                                          ?.user
                                                          ?.profilePicture
                                                          ?.url ??
                                                      null,
                                                ),
                                              ));
                                        },
                                      )
                                    : OutlineButton(
                                        child: Text("EDIT PROFILE",
                                            style:
                                                TextStyle(color: exoticPurple)),
                                        onPressed: () {
                                          Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProfilePage()))
                                              .then((_) async {
                                            await model.loadProfile(userID);
                                          });
                                        },
                                      ),
                              ),
                              model.externalUser
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.phone,
                                        color: primaryColor,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        String url = "tel:" +
                                            model.userDetail.user.phone;
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          BotToast.showText(
                                              text: "Invalid number");
                                        }
                                      },
                                    )
                                  : SizedBox(width: 20),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 12)),
                        SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              // IconButton(
                              //   icon: Icon(Icons.mail),
                              //   color: model.userDetail.user.email == null
                              //       ? Colors.grey[400]
                              //       : Color(0xFF4A90E2),
                              //   onPressed: () async {
                              //     if (model.userDetail.user.email.isNotEmpty) {
                              //       String url =
                              //           'mailto:${model.userDetail.user.email}?subject=Discussion&body=I%20would%20like%20to%20talk...';
                              //       if (await canLaunch(url)) {
                              //         await launch(url);
                              //       } else {
                              //         // throw 'Could not launch $url';
                              //         BotToast.showText(
                              //             text:
                              //                 "Sorry! The provided email is incorrect");
                              //       }
                              //       Navigator.pop(context);
                              //     }
                              //   },
                              // ),
                              IconButton(
                                icon: Icon(Icons.web),
                                color: model.userDetail.user.websiteLink == null
                                    ? Colors.grey[400]
                                    : Color(0xFF4A90E2),
                                onPressed: () {
                                  if (model.userDetail.user.websiteLink !=
                                      null) {
                                    Clipboard.setData(ClipboardData(
                                        text:
                                            model.userDetail.user.websiteLink));
                                    BotToast.showText(
                                      text: 'Link Copied!',
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
                              IconButton(
                                icon: SvgPicture.asset(
                                    "lib/assets/facebook.svg",
                                    height: 24,
                                    width: 24,
                                    color: model.userDetail.user.facebookLink ==
                                            null
                                        ? Colors.grey[400]
                                        : Colors.blue),
                                onPressed: () {
                                  if (model.userDetail.user.facebookLink !=
                                      null) {
                                    Clipboard.setData(ClipboardData(
                                        text: model
                                            .userDetail.user.facebookLink));
                                    BotToast.showText(
                                      text: 'Link Copied!',
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
                              IconButton(
                                icon: SvgPicture.asset(
                                  "lib/assets/instagram.svg",
                                  height: 24,
                                  width: 24,
                                  color:
                                      model.userDetail.user.facebookLink == null
                                          ? Colors.grey[400]
                                          : Color(0xFF4A90E2),
                                ),
                                onPressed: () {
                                  if (model.userDetail.user.facebookLink !=
                                      null) {
                                    Clipboard.setData(ClipboardData(
                                        text: model
                                            .userDetail.user.facebookLink));
                                    BotToast.showText(
                                      text: 'Link Copied!',
                                      wrapToastAnimation:
                                          (controller, cancel, Widget child) =>
                                              CustomAnimationWidget(
                                        controller: controller,
                                        child: child,
                                      ),
                                    );
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                        SliverPersistentHeader(
                          delegate: SliverColorTabBarDelegate(
                            ColoredTabBar(
                              Colors.white,
                              TabBar(
                                isScrollable: true,
                                labelColor: Colors.black87,
                                indicatorColor: exoticPurple,
                                tabs: [
                                  Tab(text: "ABOUT"),
                                  Tab(
                                      text: model.externalUser
                                          ? "PROPERTIES"
                                          : "MY PROPERTIES"),
                                  Tab(
                                      text: model.externalUser
                                          ? "SERVICES"
                                          : "MY SERVICES"),
                                ],
                              ),
                            ),
                          ),
                          pinned: true,
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: <Widget>[
                        _buildAboutSection(
                            model.userDetail,
                            model.uploadAboutImages,
                            model.updateAboutImages,
                            model.externalUser,
                            context),
                        _buildAdSection(
                          context,
                          userID,
                        ),
                        _buildServicesSection(
                          context,
                          userID,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAboutSection(UserDetail about, Function uploadFunction,
      Function deleteFunction, bool isExternalUser, BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Visibility(
                  visible: !isExternalUser,
                  child: OutlineButton.icon(
                    icon: Icon(Icons.add_a_photo, color: primaryColor),
                    label: about.user.aboutImages.length < 5
                        ? Text(
                            "Add About Photos",
                            style: TextStyle(color: primaryColor),
                          )
                        : Text("Tap and hold an image to remove it"),
                    onPressed: () async {
                      if (about.user.aboutImages.length < 5) {
                        if (await checkAndRequestSoragePermissions()) {
                          _pickedImages = await loadAssets(
                              5 - about.user.aboutImages.length);
                        }
                        if (_pickedImages.length > 0)
                          about.user.aboutImages = await uploadFunction(
                              about.user.aboutImages, _pickedImages);
                        _pickedImages.clear();
                      } else {
                        BotToast.showText(
                          text: 'You can upload a maximum of 5 images',
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
              ]),
            )),
        SliverPadding(
          padding: EdgeInsets.all(8.0),
          sliver: SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()));
              },
              child: isExternalUser
                  ? Text(
                      about.user.aboutDescription ??
                          "About section was left empty by the user.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: generalTextColor, fontSize: 20))
                  : Text(
                      about.user.aboutDescription ??
                          "Your about info is empty!\nTap here to edit profile and write about yourself.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: generalTextColor, fontSize: 20),
                    ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverGrid(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            delegate: new SliverChildBuilderDelegate(
              (BuildContext context, int index) => Container(
                width: 117,
                height: 117,
                child: GestureDetector(
                  onLongPress: () {
                    // set up the buttons
                    if (isExternalUser) return;
                    Widget cancelButton = FlatButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    );
                    Widget continueButton = FlatButton(
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                      },
                    );

                    // set up the AlertDialog
                    AlertDialog alert = AlertDialog(
                      title: Text("Delete"),
                      content: Text(
                          "Delete this image?\nThis action cannot be undone."),
                      actions: [
                        cancelButton,
                        continueButton,
                      ],
                    );

                    // show the dialog
                    showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    ).then((bool shouldDelete) async {
                      if (shouldDelete) {
                        if (shouldDelete) {
                          await deleteFunction(index);
                        }
                      }
                    });
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageView(
                          imagesList: about.user.aboutImages,
                          startPosition: index,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        about.user.aboutImages.elementAt(index).url,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              childCount: about.user.aboutImages.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdSection(BuildContext context, String sellerID) {
    return BaseView<AdDirModel>(
        onModelReady: (model) async {
          await model.fetchAds(
            Filter(
              filterValues: {
                "field": {"seller": sellerID}
              },
            ),
          );
        },
        builder: (context, model, child) => model.state == ViewState.Busy
            ? ShimmerPlaceholder()
            : Container(
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await model.refetchAds(
                      Filter(
                        filterValues: {
                          "field": {"seller": sellerID}
                        },
                      ),
                    );
                  },
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: model.adItems.userAds.isEmpty
                            ? Center(
                                child: Text("No ads uploaded.",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 18)),
                              )
                            : GridView.builder(
                                padding: EdgeInsets.only(top: 12),
                                itemCount: model.adItems.userAds.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.45,
                                ),
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  onLongPress: () {
                                    if (userID ==
                                        Provider.of<UserBasic>(context).id)
                                      showDialog<bool>(
                                        context: context,
                                        builder: (context) =>
                                            DeleteConfirmationDialog(
                                          dialogTitle: "Delete Ad",
                                          deleteContent:
                                              "Are you sure?\nOnce deleted this service cannot be recovered.",
                                          yesButton: "Delete",
                                          noButton: "Cancel",
                                        ),
                                      ).then((bool value) async {
                                        if (value) {
                                          await model.deleteUserAd(
                                              model.adItems.userAds
                                                  .elementAt(index)
                                                  .id,
                                              index);
                                          BotToast.showText(
                                            text: 'Deleted',
                                            wrapToastAnimation: (controller,
                                                    cancel, Widget child) =>
                                                CustomAnimationWidget(
                                              controller: controller,
                                              child: child,
                                            ),
                                          );
                                        }
                                      });
                                  },
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SingleAdPage(
                                            classfiedAdID: model.adItems.userAds
                                                .elementAt(index)
                                                .id),
                                      ),
                                    );
                                  },
                                  child: PropertyCard(
                                      userAd: model.adItems.userAds
                                          .elementAt(index)),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ));
  }

  Widget _buildServicesSection(BuildContext context, String sellerID) {
    return BaseView<AdDirModel>(
      onModelReady: (model) async {
        await model.fecthServiceAds(
          Filter(
            filterValues: {
              "field": {"provider": sellerID}
            },
          ),
        );
      },
      builder: (context, model, child) => model.state == ViewState.Busy
          ? ShimmerPlaceholder()
          : Container(
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: model.serviceItems.services.isEmpty
                        ? Center(
                            child: Text("No services uploaded.",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 18)),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.only(top: 12),
                            itemCount: model.serviceItems.services.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: MediaQuery.of(context)
                                      .size
                                      .width /
                                  (MediaQuery.of(context).size.height / 0.9),
                            ),
                            itemBuilder: (context, index) => GestureDetector(
                              onLongPress: () {
                                if (userID ==
                                    Provider.of<UserBasic>(context).id)
                                  showDialog<bool>(
                                      context: context,
                                      builder: (context) =>
                                          DeleteConfirmationDialog(
                                            dialogTitle: "Delete Ad",
                                            deleteContent:
                                                "Are you sure?\nOnce deleted this item cannot be recovered.",
                                            yesButton: "Delete",
                                            noButton: "Cancel",
                                          )).then((bool value) async {
                                    if (value) {
                                      await model.deleteUserAd(
                                          model.adItems.userAds
                                              .elementAt(index)
                                              .id,
                                          index);
                                      BotToast.showText(
                                        text: 'Deleted',
                                        wrapToastAnimation: (controller, cancel,
                                                Widget child) =>
                                            CustomAnimationWidget(
                                          controller: controller,
                                          child: child,
                                        ),
                                      );
                                    }
                                  });
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServiceDetailPage(
                                        serviceID: model.serviceItems.services
                                            .elementAt(index)
                                            .id),
                                  ),
                                );
                              },
                              child: ServiceCard(
                                  service: model.serviceItems.services
                                      .elementAt(index)),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRentedSection(BuildContext context, String sellerID) {
    return BaseView<AdDirModel>(
        onModelReady: (model) async {
          await model.fetchAds(
            Filter(
              filterValues: {
                "field": {"seller": userID, "adStatus": "Disabled"}
              },
            ),
          );
        },
        builder: (context, model, child) => model.state == ViewState.Busy
            ? ShimmerPlaceholder()
            : Container(
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await model.refetchAds(
                      Filter(
                        filterValues: {
                          "field": {"seller": userID, "adStatus": "Disabled"}
                        },
                      ),
                    );
                  },
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: model.adItems.userAds.isEmpty
                            ? Center(
                                child: Text("No ads uploaded.",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 18)),
                              )
                            : GridView.builder(
                                padding: EdgeInsets.only(top: 12),
                                itemCount: model.adItems.userAds.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio:
                                      MediaQuery.of(context).size.width /
                                          (MediaQuery.of(context).size.height /
                                              0.9),
                                ),
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  onLongPress: () {
                                    print("userID: " + userID);
                                    print("providerID: " +
                                        Provider.of<UserBasic>(context).id);
                                    if (userID ==
                                        Provider.of<UserBasic>(context).id)
                                      showDialog<bool>(
                                          context: context,
                                          builder: (context) =>
                                              DeleteConfirmationDialog(
                                                dialogTitle: "Delete Ad",
                                                deleteContent:
                                                    "Are you sure?\nOnce deleted this item cannot be recovered.",
                                                yesButton: "Delete",
                                                noButton: "Cancel",
                                              )).then((bool value) async {
                                        if (value) {
                                          await model.deleteUserAd(
                                              model.adItems.userAds
                                                  .elementAt(index)
                                                  .id,
                                              index);
                                          BotToast.showText(
                                            text: 'Deleted',
                                            wrapToastAnimation: (controller,
                                                    cancel, Widget child) =>
                                                CustomAnimationWidget(
                                              controller: controller,
                                              child: child,
                                            ),
                                          );
                                        }
                                      });
                                  },
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SingleAdPage(
                                            classfiedAdID: model.adItems.userAds
                                                .elementAt(index)
                                                .id),
                                      ),
                                    );
                                  },
                                  child: PropertyCard(
                                      userAd: model.adItems.userAds
                                          .elementAt(index)),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ));
  }

  Future<List<Asset>> loadAssets(int maxCount) async {
    List<Asset> resultList;
    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: maxCount, enableCamera: true);
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
}
