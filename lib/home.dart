import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytodo/layouts/moble/home_layout.dart';
import 'package:mytodo/layouts/tablet/home_layout_tablet.dart';

// HomeScreen Widget
class HomePage extends StatelessWidget {
  final String title;

  HomePage({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        if(MediaQuery.of(context).size.width > 600) return HomeLayoutTablet();
        else return HomeLayout();
      },),
    );
  }
}