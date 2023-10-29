import 'package:flutter/material.dart';
import 'package:myevents/backend/filters_service.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/pojos/filter.dart';

import '../locator.dart';

class SearcListPage extends StatefulWidget {
  final Function backDropCallback;

  const SearcListPage({Key key, this.backDropCallback}) : super(key: key);
  @override
  _SearcListPageState createState() => _SearcListPageState();
}

class _SearcListPageState extends State<SearcListPage> {
  bool _filterPerks = false;

  Filter appliedFilter = Filter();
  final FilterService _filterService = locator<FilterService>();

  TextEditingController _propertyAddressController = TextEditingController();
  TextEditingController _areaController = TextEditingController();
  TextEditingController _spaceController = TextEditingController();
  TimeOfDay start;
  TimeOfDay end;
  DateTime startTime;
  DateTime endTime;

  String startTimeStr;
  String endTimeStr;
  bool _sortDecending = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(4)),
            child: ListTile(
              trailing: Icon(Icons.place, color: Colors.white),
              title: TextField(
                style: TextStyle(color: Colors.white),
                controller: _propertyAddressController,
                decoration: new InputDecoration.collapsed(
                  hintText: "Property Address",
                  hintStyle: TextStyle(color: Colors.grey[350]),
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
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(4)),
              child: ListTile(
                trailing: Icon(Icons.access_time, color: Colors.white),
                title: Text(
                    "${start?.format(context)?.toString() ?? "Start"} - ${end?.format(context)?.toString() ?? "End"}",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            onTap: () {
              // Open a dialogue to pick from and to time i.e Time Picker
              showDialog(
                  context: context,
                  builder: (context) =>
                      Dialog(child: _selectTimeDialog(context)));
            },
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(4)),
            child: ListTile(
              trailing: Checkbox(
                checkColor: primaryColor,
                activeColor: Colors.white,
                value: _filterPerks,
                onChanged: (bool perksCheck) {
                  setState(() {
                    _filterPerks = perksCheck;
                  });
                },
              ),
              title: Text("Perks", style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Sort Result by Price",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          Row(
            children: <Widget>[
              new Radio<bool>(
                activeColor: Colors.white,
                value: true,
                groupValue: _sortDecending,
                onChanged: (bool val) {
                  setState(() {
                    _sortDecending = val;
                  });
                },
              ),
              new Text(
                'Low to High',
                style: new TextStyle(fontSize: 16.0, color: Colors.white),
              ),
              new Radio<bool>(
                activeColor: Colors.white,
                value: false,
                groupValue: _sortDecending,
                onChanged: (bool val) {
                  setState(() {
                    _sortDecending = val;
                  });
                },
              ),
              new Text(
                'High to Low',
                style: new TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ],
          ),
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
                  Filter filter = Filter(filterValues: {
                    "sort": _sortDecending ? "price:asc" : "price:desc",
                    "field": <String, dynamic>{
                      "address_contains": _propertyAddressController.text,
                      "timeStart_gte": startTimeStr ?? null,
                      "timeEnd_lte": startTimeStr ?? null,
                      "area_gte": int.tryParse(_areaController.text.trim()),
                      "accommodation_gte":
                          int.tryParse(_spaceController.text),
                      "perks_null": !_filterPerks
                    }
                  });
                  // Broadcasting  the filters so that DirectoryPage can use and apply them
                  appliedFilter = filter;
                  _filterService.filterController.add(appliedFilter);
                },
              ),
              OutlineButton(
                borderSide: BorderSide(color: Colors.grey),
                child: Text("CLEAR", style: TextStyle(color: Colors.white)),
                color: Colors.white,
                onPressed: () {
                  // Nulling the filters
                  _filterService.filterController.add(null);
                },
              ),
            ],
          ),
        ],
      ),
    );
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
}
