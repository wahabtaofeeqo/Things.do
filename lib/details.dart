import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytodo/todo.dart';

class DetailsPage extends StatelessWidget {

  final Todo todo;
  DetailsPage({this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text("Just The Beginning"),
        ),
      ),
    );
  }
}