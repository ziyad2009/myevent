import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/common/custom_animation.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/pojos/user_detail.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> updatedFields = {};

  bool inAsync = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text("Edit Profile"),
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
          Mutation(
            options: MutationOptions(
              documentNode: gql(updateUser),
              update: (Cache cache, QueryResult result) {
                return result;
              },
              onError: (OperationException exp) {
                BotToast.showText(text: "Update errored: $exp");
                setState(() {
                  inAsync = false;
                });
              },
              onCompleted: (dynamic resultData) {
                setState(() {
                  inAsync = false;
                });

                BotToast.showText(
                  text: 'Profile Updated',
                  wrapToastAnimation: (controller, cancel, Widget child) =>
                      CustomAnimationWidget(
                    controller: controller,
                    child: child,
                  ),
                );
              },
            ),
            builder: (RunMutation runMutation, QueryResult result) =>
                FlatButton(
              child: Text(
                "UPDATE",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  setState(() {
                    inAsync = true;
                  });
                  _formKey.currentState.save();
                  runMutation({
                    "fields": <String, dynamic>{
                      "where": <String, dynamic>{
                        "id": Provider.of<UserBasic>(context).id
                      },
                      "data": updatedFields
                    }
                  });
                }
              },
            ),
          )
        ],
      ),
      body: inAsync
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Query(
                      options: QueryOptions(
                          documentNode: gql(profileInfoQuery),
                          variables: <String, dynamic>{
                            "field": Provider.of<UserBasic>(context).id
                          }),
                      builder: (QueryResult result,
                          {VoidCallback refetch, FetchMore fetchMore}) {
                        if (result.exception != null) {
                          return Text(result.exception.toString());
                        }

                        if (result.loading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        UserDetail userBasic = UserDetail.fromJson(result.data);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            sectionHeader("Basic Info"),
                            SizedBox(
                              height: 8,
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              initialValue: userBasic.user.fullName,
                              onSaved: (String value) {
                                updatedFields["fullName"] = value;
                              },
                              validator: (String value) => value.isEmpty
                                  ? "Name must not be empty"
                                  : null,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                  hintText: "Full Name", labelText: "Name"),
                            ),
                            // TextFormField(
                            //   initialValue: userBasic.user.username,
                            //   onSaved: (String value) {
                            //     updatedFields["username"] = value;
                            //   },
                            //   validator: (String value) => value.isEmpty
                            //       ? "Username must not be empty"
                            //       : null,
                            //   textCapitalization: TextCapitalization.words,
                            //   decoration: InputDecoration(
                            //       hintText: "Username", labelText: "Username"),
                            // ),
                            TextFormField(
                              maxLength: 9,
                              enabled: false,
                              initialValue: userBasic.user.phone,
                              keyboardType: TextInputType.phone,
                              onSaved: (String value) {
                                updatedFields["phone"] = value;
                              },
                              validator: (String value) => value.isEmpty
                                  ? "Mobile must not be empty"
                                  : null,
                              decoration: InputDecoration(
                                  hintText: "Mobile Number",
                                  labelText: "Mobile"),
                            ),
                            TextFormField(
                              initialValue: userBasic.user.shortBio,
                              onSaved: (String value) {
                                updatedFields["shortBio"] = value;
                              },
                              maxLength: 30,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                  hintText: "Short Bio", labelText: "Bio"),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              initialValue: userBasic.user.aboutDescription,
                              onSaved: (String value) {
                                updatedFields["aboutDescription"] = value;
                              },
                              maxLines: 5,
                              maxLength: 250,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "About Description",
                                  labelText: "About"),
                            ),
                            TextFormField(
                              initialValue: userBasic.user.facebookLink,
                              onSaved: (String value) {
                                updatedFields["facebookLink"] = value;
                              },
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                  hintText: "Facebook Account",
                                  labelText: "Facebook(Optional)"),
                            ),
                            TextFormField(
                              initialValue: userBasic.user.websiteLink,
                              validator: (val) {
                                if (val.toString().isEmpty) return null;
                                return RegExp(
                                            r"^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$")
                                        .hasMatch(val)
                                    ? null
                                    : "Incorrect web address";
                              },
                              onSaved: (String value) {
                                updatedFields["websiteLink"] = value;
                              },
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                  hintText: "Website Address",
                                  labelText: "Website(Optional)"),
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            // sectionHeader("Advanced Options"),
                            // SizedBox(
                            //   height: 8,
                            // ),
                            // OutlineButton(
                            //   child: Text(
                            //     "Reset Password",
                            //     style: TextStyle(color: primaryColor),
                            //   ),
                            //   onPressed: () {
                            //     Fluttertoast.showToast(
                            //         msg: "Coming Soon!",
                            //         gravity: ToastGravity.CENTER);
                            //   },
                            // )
                          ],
                        );
                      }),
                ),
              ),
            ),
    );
  }
}
