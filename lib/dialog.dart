import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytodo/consts.dart';
import 'package:mytodo/data/firebase_records.dart';
import 'package:mytodo/database.dart';
import 'package:mytodo/layouts/login_screen.dart';
import 'package:mytodo/register.dart';
import 'package:mytodo/utils.dart';

// EmailDialog Widget
class EmailDialogWidget extends StatefulWidget {

  final _formKey = GlobalKey<FormState>();

  @override
  State<StatefulWidget> createState() {
    return _EmailDialogWidgetState();
  }
}

class _EmailDialogWidgetState extends State<EmailDialogWidget> {

  final _controller = new TextEditingController();
  final _dataManager = DataManager.getInstance();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.padding)
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      child: Stack(
        children: <Widget>[
          _dialogView(context),
          _circleView(context),
        ],
      ),
    );
  }

  Widget _dialogView(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: Constants.avatarPadding + Constants.padding,
          right: Constants.padding,
          bottom: Constants.padding,
          left: Constants.padding
      ),

      margin: EdgeInsets.only(
        top: Constants.avatarPadding,
      ),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(Constants.padding),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0)
            )
          ]
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Text(
              "Email Address",
              style: Theme.of(context).textTheme.title,
              textAlign: TextAlign.left,
            ),
          ),
          _formView(context)
        ],
      ),
    );
  }

  Widget _circleView(BuildContext context) {
    return Positioned(
      left: Constants.padding,
      right: Constants.padding,
      child: CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 55.0,
        child: Text("E", textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
      ),
    );
  }

  Widget _formView(BuildContext context) {
    return Material(
      color: Colors.white,
      child:  Form(
        key: widget._formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Example@domain.com",
              ),
              validator: (value) {
                return (value.isEmpty) ? "Enter Your Email" : null;
              },
            ),

            Padding(
                padding: EdgeInsets.only(top: Constants.padding),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Constants.padding)
                    ),
                    color: Colors.blue,
                    child: Text("Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    onPressed: () {
                      if(widget._formKey.currentState.validate()) {
                        _saveEmail(context, _controller.text);
                      }
                    },
                  ),
                )
            )
          ],
        ),
      ),
    );
  }

  _saveEmail(BuildContext context, String email) async {

    var firebase = FirebaseRecords();
    bool res = await firebase.emailExists(email);
    if(!res) {
      Navigator.of(context).pop(); // Close the dialog
      Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return SignUp(email: email);
          }
      ));
    }
    else {
      Utils.showMessage("The Email has already been registered. Login", context);
      Navigator.of(context).pop(); // Close the Dialog
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (context) => LoginScreen(email)
      ));
    }
  }
}