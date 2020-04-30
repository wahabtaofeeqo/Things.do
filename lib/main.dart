import 'package:flutter/material.dart';
import 'package:mytodo/database.dart';
import 'package:mytodo/details.dart';
import 'package:mytodo/dialog.dart';
import 'package:mytodo/home.dart';
import 'package:mytodo/session.dart';
import 'package:mytodo/welcome.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {

  runApp(MaterialApp(
    title: "Things.do",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
            title: GoogleFonts.lato(textStyle: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: GoogleFonts.lato(textStyle: TextStyle(fontSize: 16.0, color: Colors.black26, height: 1.5, fontWeight: FontWeight.bold))
        ),
    ),
    home: MyApp()
  )
  );
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  final _session = SessionManager.getInstance();
  bool state;

  @override
  void initState() {

    _session.isFirstTime().then((val) {
      state = val;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch(state) {
      case true:
        return Welcome(title: "Welcome",);
        break;

      case false:
        return HomePage(title: "My Tasks",);
        break;

      default:
        return HomePage(title: "My Tasks",);
    }
  }
}