
import 'package:flutter/material.dart';
import 'package:mytodo/widgets/welcomeWidget.dart';

class WelcomeLayoutTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Padding(
        padding: EdgeInsets.only(top: 16, left: 150, right: 150),
        child:  Center(
          child: WelcomeWidget(),
        ),
      ),
    );
  }
}