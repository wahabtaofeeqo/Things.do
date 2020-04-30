import 'package:flutter/material.dart';
import 'package:mytodo/database.dart';
import 'package:mytodo/todo.dart';
import 'package:table_calendar/table_calendar.dart';

class AddTaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
  DateTime _day;
  bool _alarm = true;
  bool _today = false;

  final _formKey = GlobalKey<FormState>();
  CalendarController _calendarController;
  AnimationController _animationController;

  final _dataManager = DataManager.getInstance();

  @override
  void initState() {

    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400)
    );

    _animationController.forward();

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
      appBar: AppBar(
        title: Text("New Task"),
      ),
      body: Material(
        child: ListView(
          children: <Widget>[
            _calendarWidget(),
            _addWidget()
          ],
        ),
      ),
    );
  }

  _onDaySelected(DateTime day, List events) {
    _day = day;
  }

  Widget _calendarWidget() {
    return TableCalendar(
      calendarController: _calendarController,
      availableGestures: AvailableGestures.horizontalSwipe,
      onDaySelected: _onDaySelected,
      calendarStyle: CalendarStyle(
        renderDaysOfWeek: false,
        renderSelectedFirst: false,
        contentPadding: EdgeInsets.only(top: 16.0, bottom: 16.0),
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: true,
      ),
    );
  }

  Widget _addWidget() {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: BoxDecoration(
            color: Colors.white
        ),
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

                    Text("Alarm: "),
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

    var date = _day.year.toString() + "-" + _day.month.toString() + "-" + _day.day.toString();
    var todo = new Todo(_title, _desc, date);
    await _dataManager.insert(todo);
  }
}