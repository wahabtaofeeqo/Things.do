import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytodo/database.dart';
import 'package:mytodo/todo.dart';
import 'package:mytodo/utils.dart';
import 'package:table_calendar/table_calendar.dart';

class AddTaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AddTaskWidget();
  }
}

class AddTaskWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _AddTaskWidgetState();
  }
}

class _AddTaskWidgetState extends State<AddTaskWidget> with TickerProviderStateMixin {

  String _title = "";
  String _desc = "";
  bool _alarm = true;
  bool _today = false;

  DateTime _day;
  TimeOfDay _time;

  final _formKey = GlobalKey<FormState>();
  CalendarController _calendarController;
  AnimationController _animationController;

  static const platform = const MethodChannel("com.taocoder.todo/alarm");
  final _dataManager = DataManager.getInstance();

  @override
  void initState() {

    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400)
    );

    _animationController.forward();

    _time = TimeOfDay.now();
    super.initState();
  }

  @override
  void dispose() {

    _animationController.dispose();
    _calendarController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("New Task"),
      ),
      body: Material(
        child: ListView(
          children: <Widget>[
            _buildCalendar(),
            _addWidget()
          ],
        ),
      ),
    );
  }

  _onDaySelected(DateTime day, List events) {
    _day = day;
  }

  Widget _buildCalendar() {
    return Container(
      color: Colors.black12,
      child: TableCalendar(
        calendarController: _calendarController,
        initialCalendarFormat: CalendarFormat.twoWeeks,
        formatAnimation: FormatAnimation.slide,
        availableGestures: AvailableGestures.horizontalSwipe,
        availableCalendarFormats: const {
          CalendarFormat.twoWeeks: ''
        },
        calendarStyle: CalendarStyle(
            renderDaysOfWeek: false,
            outsideDaysVisible: true,
            contentPadding: EdgeInsets.only(top: 16.0, bottom: 16.0)
        ),
        onDaySelected: _onDaySelected,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          centerHeaderTitle: true,
        ),

        builders: CalendarBuilders(
            selectedDayBuilder: (BuildContext context, date, _) {
              return FadeTransition(
                opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
                child: Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                    width: 100,
                    height: 100,
                    child: CircleAvatar(
                      child: Text(
                        '${date.day}',
                        style: TextStyle().copyWith(fontSize: 16.0),
                      ),
                    )
                ),
              );
            },

            todayDayBuilder: (context, date, _) {
              return Container(
                  margin: const EdgeInsets.all(4.0),
                  padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                    backgroundColor: Colors.deepOrange[400],
                    child: Text(
                      '${date.day}',
                      style: TextStyle().copyWith(fontSize: 16.0, color: Colors.white),
                    ),
                  )
              );
            },

            markersBuilder: (context, date, events, holidays) {
              return <Widget>[];
            }
        ),
      ),
    );
  }

  Widget _addWidget() {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: InputDecoration(
                    icon: Icon(Icons.timer),
                    labelText: "Task Title"
                ),
                validator: (val) {
                  _title = val;
                  return (val.isEmpty) ? "Title?" : null;
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: InputDecoration(
                    icon: Icon(Icons.timer),
                    labelText: "Task Description"
                ),
                validator: (val) {
                  _desc = val;
                  return (val.isEmpty) ? "Description?" : null;
                },
              ),
            ),

            ListTile(
              title: Text("Time: ${_time.hourOfPeriod} : ${_time.minute}"),
              onTap: null,
              trailing: IconButton(
                icon: Icon(Icons.timer, color: Colors.deepOrange,),
                onPressed: () {
                  _pickTime();
                },
              ),
            ),

            Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Today: "),
                    Switch(value: _today, onChanged: (val) {
                      setState(() {
                        _today = !_today;
                      });
                    },),

                    Text("Remind me: "),
                    Switch(value: _alarm, onChanged: (val) {
                      setState(() {
                        _alarm = !_alarm;
                      });
                    }),
                  ],
                )
            ),

            Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: RaisedButton(
                color: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Text("Add Task", style: TextStyle(color: Colors.white),),
                ),
                onPressed: () {
                  if(_formKey.currentState.validate()) {
                    _onClickAddButton();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onClickAddButton() async {
    if(_today) {
      _day = DateTime.now();
    }

    if(_day != null) {
      var date = Utils.getDate(_day);

      var todo = new Todo();
      todo.title = _title;
      todo.description = _desc;
      todo.date = date;
      todo.status = 0;

      await _dataManager.insert(todo);
      print(_day);
      print(_time);

      _createAlarm(_day, _time);

      print("Task Added");
      Navigator.pop(context);
    }
  }

  _pickTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: _time);
    if(t != null) {
      setState(() {
        _time = t;
      });
    }
  }

  _createAlarm(DateTime date, TimeOfDay time) async {
    try {
      String param = date.year.toString() + " " +
          date.month.toString() + " " + date.day.toString() + " " +
          time.hour.toString() + " " + time.minute.toString();

      print(param);
      platform.invokeMethod("createAlarm", param);
    }
    on PlatformException catch(e) {
      print(e.message);
    }
  }
}