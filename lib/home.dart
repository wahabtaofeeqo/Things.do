import 'package:flutter/material.dart';
import 'package:mytodo/addTask.dart';
import 'package:mytodo/database.dart';
import 'package:mytodo/session.dart';
import 'package:mytodo/todo.dart';
import 'package:table_calendar/table_calendar.dart';

// HomeScreen Widget
class HomePage extends StatefulWidget {

  final String title;
  HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

// HomeScreenState
class _HomePageState extends State<HomePage> with TickerProviderStateMixin {

  final _session = SessionManager.getInstance();
  final _dataManager = DataManager.getInstance();
  CalendarController _calendarController;
  AnimationController _animationController;

  GlobalKey<ScaffoldState> _state = new GlobalKey<ScaffoldState>();
  var date;
  
  @override
  void initState() {
    _session.setIsFirstTime(false);
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400)
    );
    
    var _day = DateTime.now();
    date = _day.year.toString() + "-" + _day.month.toString() + "-" + _day.day.toString();
    
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
      key: _state,
      appBar: AppBar(
        title: ListTile(
          subtitle: Text("Wednesday March, 2020", style: TextStyle(color: Colors.black26),),
          title: Text("Things to do", style: TextStyle(color: Colors.white),),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.linear_scale,),
            onPressed: () {},
          )
        ],
        leading: IconButton(
          icon: Icon(Icons.menu,),
          onPressed: () {
            _state.currentState.openDrawer();
          },
        )
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<List>(
          future: _dataManager.todosToday(date),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if(snapshot.hasError) print(snapshot.error);
            if(snapshot.hasData) {
              List list = snapshot.data;
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  Todo todo = list.elementAt(index);
                  return _itemBox(todo);
                },
              );
            }
            else {
              return Center(child:  CircularProgressIndicator(),);
            }
          },
        ),
      ),
      drawer: _drawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return AddTaskPage();
            }
          ));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add, color: Colors.black,),
        backgroundColor: Colors.white,
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _itemBox(Todo todo) {
    return Dismissible(
      key: Key(todo.title),
      direction: DismissDirection.horizontal,
      child: Container(
        margin: EdgeInsets.only(bottom: 5.0),
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(45.0))
          ),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: ListTile(
              title: Text(todo.title),
              subtitle: Text(todo.description.substring(0)),
              leading: Icon(Icons.stars, color: Colors.deepOrange,),
              trailing: GestureDetector(
                child: Icon(Icons.linear_scale),
                onTap: () {
                   _popup();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      availableGestures: AvailableGestures.horizontalSwipe,
      calendarStyle: CalendarStyle(
        contentPadding: EdgeInsets.only(top: 16.0, bottom: 16.0),
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
    );
  }

  Widget _popup() {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 1,
            child: GestureDetector(
              child: Text("Delete Task"),
            ),
          ),

          PopupMenuItem(
            value: 1,
            child: GestureDetector(
              child: Text("Mark as complete"),
            ),
          ),

          PopupMenuItem(
            value: 1,
            child: GestureDetector(
              child: Text("Cancel"),
              onTap: () {
                print("OK");
              },
            ),
          )
        ];
      },
    );
  }
  Widget _drawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(
                  color: Colors.black26
              ),
              child: Text("TaoCoder")
          ),
        ],
      ),
    );
  }
}
