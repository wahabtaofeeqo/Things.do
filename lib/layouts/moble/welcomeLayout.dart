import 'package:flutter/material.dart';
import 'package:mytodo/widgets/welcomeWidget.dart';

class WelcomeLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: WelcomeWidget(),
        ),
      ),
    );
  }
}