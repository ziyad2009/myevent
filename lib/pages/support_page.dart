import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/common/custom_animation.dart';
import 'package:myevents/graphql/mutations.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _supportFormKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _commentsController = TextEditingController();
  bool _inAsync = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _supportFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: new InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  hintText: "Name",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.0),
                  ),
                ),
                validator: (val) =>
                    _nameController.text.isNotEmpty ? null : 'Name is required',
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: new InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.0),
                  ),
                ),
                validator: (val) => _emailController.text.isNotEmpty
                    ? null
                    : 'Email is required',
              ),
              SizedBox(height: 8),
              TextFormField(
                maxLength: 9,
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: new InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  hintText: "51 *** ****",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.0),
                  ),
                ),
                validator: (val) => _mobileController.text.isNotEmpty
                    ? null
                    : 'Mobile is required',
              ),
              SizedBox(height: 8),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                controller: _cityController,
                decoration: new InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  hintText: "City",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.0),
                  ),
                ),
                validator: (val) =>
                    _cityController.text.isNotEmpty ? null : 'City is required',
              ),
              SizedBox(height: 8),
              TextFormField(
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                controller: _commentsController,
                decoration: new InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  hintText: "Comments",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.0),
                  ),
                ),
                validator: (val) => _commentsController.text.isNotEmpty
                    ? null
                    : 'Please write a comment or complaint',
              ),
              SizedBox(height: 12),
              Mutation(
                  options: MutationOptions(
                    documentNode: gql(createSupport),
                    onCompleted: (dynamic resultData) {
                      BotToast.showText(
                        text: 'Support request submitted',
                        wrapToastAnimation:
                            (controller, cancel, Widget child) =>
                                CustomAnimationWidget(
                          controller: controller,
                          child: child,
                        ),
                      );
                      setState(() {
                        _inAsync = false;
                      });
                    },
                  ),
                  builder: (RunMutation runMutation, QueryResult result) {
                    return _inAsync
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.maxFinite,
                            child: RaisedButton(
                              color: primaryColor,
                              child: Text(
                                "SUBMIT",
                                style: raisedTextStyle,
                              ),
                              onPressed: () {
                                if (_supportFormKey.currentState.validate()) {
                                  setState(() {
                                    _inAsync = true;
                                  });
                                  runMutation({
                                    "field": {
                                      "data": {
                                        "name": _nameController.text.trim(),
                                        "email": _emailController.text.trim(),
                                        "mobile": _mobileController.text.trim(),
                                        "city": _cityController.text.trim(),
                                        "comments":
                                            _commentsController.text.trim()
                                      }
                                    }
                                  });
                                }
                              },
                            ),
                          );
                  }),
              SizedBox(height: 12),
              _createSectionHeader("CALL US"),
              Text("0800 1234 5678",
                  style: TextStyle(color: Colors.black, fontSize: 36)),
              _createSectionHeader("EMAIL US"),
              Text("talk@myevents.com",
                  style: TextStyle(color: Colors.black, fontSize: 36)),
              SizedBox(
                height: 8,
              ),
              Text(
                "My Events\nSaeed Alam Tower, 37-Commercial Zone Liberty Market, Gulberg, Lahore, Pakistan.\nMonday-Saturday\n10:00am-07:00pm",
                style: TextStyle(color: Colors.grey[600]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _createSectionHeader(String title) {
    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.grey[400],
      //   borderRadius: BorderRadius.circular(4),
      // ),
      padding: EdgeInsets.all(8.0),
      child: Text(
        title.toUpperCase() ?? "",
        style:
            TextStyle(letterSpacing: 1, fontSize: 12, color: Color(0x99333333)),
      ),
    );
  }
}
