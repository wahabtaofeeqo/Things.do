import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytodo/layouts/moble/welcomeLayout.dart';
import 'package:mytodo/layouts/tablet/welcome_layout_tablet.dart';
import 'package:mytodo/session.dart';


class Welcome extends StatelessWidget {

  final String title;
  final manager = SessionManager.getInstance();

  Welcome({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        if(MediaQuery.of(context).size.width > 600) {
          print("Tablet");
          return WelcomeLayoutTablet();
        }
        else {
          print("Mobile");
          return WelcomeLayout();
        }
      },),
    );
  }
}