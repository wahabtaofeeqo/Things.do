import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytodo/database.dart';
import 'package:mytodo/home.dart';
import 'package:mytodo/welcome.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/session.dart';


final _dataManager = DataManager.getInstance();

void main() {
  //runApp(DevicePreview(builder: (context) => MyApp(), enabled: !kReleaseMode,));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //locale: DevicePreview.of(context).locale,
      //builder: DevicePreview.appBuilder,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
              title: GoogleFonts.lato(textStyle: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle: GoogleFonts.lato(textStyle: TextStyle(fontSize: 16.0, color: Colors.black26, height: 1.5, fontWeight: FontWeight.bold))
          ),
      ),
      home: MainView(),
    );
  }
}

class MainView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainViewState();
  }
}

class _MainViewState extends State<MainView> {

  bool checked = false;
  bool registered = false;
  final _session = SessionManager.getInstance();
  static const channelAlarm = const MethodChannel("com.taocoder.todo/alarm");

  @override
  void initState() {
    super.initState();
    initApp();
  }

  initApp() {
    _dataManager.hasRegister().then((res) {
      setState(() {
        checked = true;
        registered = res;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(checked) {
      return (registered) ? HomePage(title: "Home",) : Welcome();
    }
    else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

//Todo 1: Create Notification on platform notice