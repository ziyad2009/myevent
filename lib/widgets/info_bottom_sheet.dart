import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:provider/provider.dart';

class GetInfoSheet extends StatefulWidget {
  @override
  _GetInfoSheetState createState() => _GetInfoSheetState();
}

class _GetInfoSheetState extends State<GetInfoSheet> {
  TextEditingController _nameController;
  TextEditingController _phoneCotroller;
  Map<String, dynamic> updateFields = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                "About You",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                  "Please fill-out these details before posting a property for rent",
                  style: TextStyle(color: Colors.grey)),
              leading: Icon(Icons.account_circle, color: primaryColor),
              trailing: Mutation(
                  options: MutationOptions(
                    documentNode: gql(updateUser),
                    update: (Cache cache, QueryResult result) {
                      return result;
                    },
                    onCompleted: (dynamic resultData) {
                      print(resultData);
                      Provider.of<UserBasic>(context).fullName =
                          _nameController.text;
                      Provider.of<UserBasic>(context).phone =
                          _phoneCotroller.text;
                      Navigator.pop(context);
                    },
                  ),
                  builder: (RunMutation runMutation, QueryResult result) {
                    if (result.hasException) {
                      return Text(result.exception.toString());
                    }

                    if (result.loading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return FlatButton(
                      child: Text("SAVE",
                          style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600)),
                      onPressed: () {
                        updateFields["fullName"] = _nameController.text;
                        updateFields["phone"] = _phoneCotroller;
                        runMutation({
                          "fields": <String, dynamic>{
                            "where": <String, dynamic>{
                              "id": Provider.of<UserBasic>(context).id
                            },
                            "data": updateFields
                          }
                        });
                      },
                    );
                  }),
            ),
            Divider(),
            TextField(
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              controller: _nameController,
              decoration:
                  InputDecoration(hintText: "Full Name", labelText: "Name"),
            ),
            TextField(
              controller: _phoneCotroller,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.phone,
              decoration:
                  InputDecoration(hintText: "Phone Number", labelText: "Phone"),
              maxLength: 11,
            ),
          ],
        ),
      ),
    );
  }
}
