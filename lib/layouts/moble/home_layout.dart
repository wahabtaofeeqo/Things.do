import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytodo/addTask.dart';
import 'package:mytodo/data/firebase_records.dart';
import 'package:mytodo/database.dart';
import 'package:mytodo/user.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../todo.dart';
import '../../utils.dart';

class HomeLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeLayoutState();
  }
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin {

  final _dataManager = DataManager.getInstance();

  var _date;
  var _currentTab = "All";
  var _active = "All";

  Future<List<Todo>> _futureTodo;

  CalendarController _calendarController;
  AnimationController _animationController;

  static const channelAlarm = const MethodChannel("com.taocoder.todo/alarm");

  @override
  void initState() {

    super.initState();

    // Calendar
    _calendarController = CalendarController();
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400)
    );
    _animationController.forward();

//    // Today's Date
    _date = Utils.getDate(DateTime.now());

    _populate();

    channelAlarm.setMethodCallHandler((call) => _handler(call));
  }

  _handler(MethodCall call) {
    if(call.method == "taskToday") {
      print("Things today b");
    }
  }

  @override
  void dispose() {

    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  // Populate the task list
  _populate([String date, int status]) async {

    Future<List<Todo>> temp;
    bool available = true;

    // Date & Status are set (For Active and Completed Todos)
    if(date != null && status != null) {
      temp = _dataManager.getTasks(date, status);
      if((await temp).length > 0) {
        _futureTodo = temp;
      }
      else {
        available = false;
      }
    }
    else if(date != null) { //Only Date is set (This Day Tab)
      temp = _dataManager.todosToday(date);
      if((await temp).length > 0) {
        _futureTodo = temp;
      }
      else {
        available = false;
      }
    }
    else if(status != null) {
      temp = _dataManager.tasksWithStatus(status);
      if((await temp).length > 0) {
        _futureTodo = temp;
      }
      else {
        available = false;
      }
    }
    else { // Default (All the Todos)
      _futureTodo = _dataManager.todos();
    }

    if(!available) Utils.showMessage("No Record Found", context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Things to do"),
        centerTitle: true,
        leading: Icon(Icons.title,),
      ),
      body: Container(
        child: FutureBuilder<List> (
          future: _futureTodo,
          builder: (context, snapshot) {
            if(snapshot.hasError) Utils.showMessage(snapshot.error.toString(), context);
            if(snapshot.hasData) {
              List data = snapshot.data;
              if(data.length == 0) return Center(child: Text("Your List of Things is Empty", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),);
              else return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, i) {
                  if(i == 0) {
                    return Column(
                      children: <Widget>[
                        _buildCalendar(),
                        _buildTabs(),
                        _itemBox(data.elementAt(i))
                      ],
                    );
                  }
                  else {
                    return _itemBox(data.elementAt(i));
                  }
                },
              );
            }
            else {
              return Center(child: CircularProgressIndicator(),);
            }
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: () {
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (context) => AddTaskPage()
        ));
      },),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTabs() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildTab("All"),
        _buildTab("This Day"),
        _buildTab("Active"),
        _buildTab("Completed")

      ],
    );
  }

  // This represent a Button in the list of above buttons
  Widget _buildTab(String title) {
    return FlatButton(
      child: Text(title, style: TextStyle(color: identical(_active, title) ? Colors.white : Colors.blue),),
      color: (identical(_active, title)) ? Colors.deepOrange : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      onPressed: () async {

        // Title of the button
        _active = title;

        switch(title) {

          case "All":

            if(!identical(_currentTab, _active)) {
              _currentTab = title;
              _futureTodo = _dataManager.todos();
            }
            break;

          case "Active":

            if(!identical(_currentTab, _active)) {
              _currentTab = title;
              await _populate(null, 0);
            }
            break;

          case "Completed":
            if(!identical(_currentTab, _active)) {
              _currentTab = title;
              await _populate(null, 1);
            }
            break;

          case "This Day":
            if(!identical(_currentTab, _active)) {
              _currentTab = title;
              await _populate(_date);
            }
            break;

          default:
            Utils.showMessage("No defined", context);
        }

        setState(() {});
      },
    );
  }

  Widget _buildCalendar() {
    return Container(
      color: Colors.black12,
      child: TableCalendar(
        calendarController: _calendarController,
        initialCalendarFormat: CalendarFormat.week,
        formatAnimation: FormatAnimation.slide,
        availableGestures: AvailableGestures.horizontalSwipe,
        availableCalendarFormats: const {
          CalendarFormat.week: ''
        },
        headerVisible: false,
        calendarStyle: CalendarStyle(
            renderDaysOfWeek: false,
            outsideDaysVisible: true,
            contentPadding: EdgeInsets.only(top: 16.0, bottom: 16.0)
        ),
        onDaySelected: (date, events) {
          _date = Utils.getDate(date);
        },
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
                    backgroundColor: Colors.amber[400],
                    child: Text(
                      '${date.day}',
                      style: TextStyle().copyWith(fontSize: 16.0),
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

  // Card
  Widget _itemBox(Todo todo) {
    return Dismissible(
      key: Key(todo.title),
      direction: DismissDirection.horizontal,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0),
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(35.0), topRight: Radius.circular(35.0))
          ),
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: _buildListTile(todo)
          ),
        ),
      ),
    );
  }

  // Card Item
  Widget _buildListTile(Todo todo) {
    return ListTile(
      title: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          todo.title,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18.0,
              decoration: (todo.status == 1) ? TextDecoration.lineThrough : TextDecoration.none
          ),
        ),
      ),
      subtitle: Text(todo.description.substring(0)),
      leading: Icon(Icons.stars, color: Colors.deepOrange,),
      trailing: GestureDetector(
        child: Icon(Icons.more_vert),
        onTapDown: (details) {
          _showMenu(details.globalPosition, todo);
        },
      ),
      onTap: () {
        _showDetails(todo);
      },
    );
  }

  // Card PopupMenu
  _showMenu(Offset offset, Todo todo) async {
    double left = offset.dx;
    double top = offset.dy;
    String value = "";
    await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(left, top, 0, 0),
        initialValue: value,
        items: [
          PopupMenuItem<void>(
              child: ListTile(
                title: Text("Delete"),
                onTap: () async {
                  await _dataManager.deleteTask(todo.id);
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              value: 'Delete'
          ),
          PopupMenuItem<String>(
              value: 'Marke as complete',
              child: ListTile(
                title: Text((todo.status == 1) ? "Unmark as complete" : "Mark as complete"),
                onTap: () async {

                  if(todo.status == 1) {
                    await _dataManager.markComplete(todo.id, 0);
                  }
                  else {
                    await _dataManager.markComplete(todo.id, 1);
                  }

                  setState(() {
                    _populate();
                  });
                  Navigator.pop(context);
                },
              )
          ),
        ],
        elevation: 8.0
    );
  }

  _showDetails(Todo todo) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 18.0),
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
              ),
              child: Stack(
                children: <Widget>[
                  _buildDetails(todo),
                  _buildButton(todo),
                ],
              )
          );
        });
  }

  // Details
  Widget _buildDetails(Todo todo) {
    return Container(
      padding: EdgeInsets.only(bottom: 70.0, top: 16.0),
      child: ListView(
        children: <Widget>[
          Text("Title", style: TextStyle(color: Colors.black45, fontSize: 16.0, fontWeight: FontWeight.w500),),
          Padding(
            padding: EdgeInsets.only(top: 14.0),
            child: Text(todo.title, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),),
          ),

          Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 10.0),
            child: Divider(color: Colors.black45),
          ),

          Text("Description", style: TextStyle(color: Colors.black45, fontSize: 16.0, fontWeight: FontWeight.w500),),
          Padding(
            padding: EdgeInsets.only(top: 14.0),
            child: Text(todo.description, style: TextStyle(fontSize: 18.0, height: 1.5),),
          ),

          Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Divider(color: Colors.black45),
          ),

          Text("Remind me this Task", style: TextStyle(color: Colors.black45, fontSize: 16.0, fontWeight: FontWeight.w500),),
          Container(
            margin: EdgeInsets.only(top: 16.0),
            decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(Radius.circular(5.0))
            ),
            child: ListTile(
              title: Text(todo.date),
              trailing: Switch(
                value: true,
                onChanged: (val) {},
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(""),
          ),

          Text("Created", style: TextStyle(color: Colors.black45, fontSize: 16.0, fontWeight: FontWeight.w500),),
          Padding(
            padding: EdgeInsets.only(top: 14.0),
            child: Text(todo.date, style: TextStyle(fontSize: 18.0, height: 1.5),),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(Todo todo) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: RaisedButton(
        padding: EdgeInsets.all(16.0),
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        color: Colors.black45,
        child: Text("Delete Task"),
        onPressed: () {},
      ),
    );
  }
}