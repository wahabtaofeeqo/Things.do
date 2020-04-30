import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytodo/account.dart';
import 'package:mytodo/consts.dart';
import 'package:mytodo/database.dart';
import 'package:mytodo/home.dart';

class FormDialog extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _FormDialogState();
  }
}

class _FormDialogState extends State<FormDialog> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Todo"),),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Card(
            child: _form(context),
          ),
        )
      )
    );
  }

  Widget _form(BuildContext context) {
    return Form(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
        children: <Widget>[
          Container(

            margin: EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.tealAccent,
              borderRadius: BorderRadius.circular(32)
            ),

            child: TextFormField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Todo Title",
                suffixIcon: Icon(Icons.print),
                contentPadding: EdgeInsets.all(16)
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32)
            ),

            child: TextFormField(
              decoration: InputDecoration(
                 labelText: "Enter Description",
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(),
                ),
              ),

              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: null,
            ),
          ),

          Container(
            margin: EdgeInsets.only(bottom: 16.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: "Enter Demo",
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(),
                ),
              ),
              maxLines: null,
              minLines: 5,
            ),
          ),

          Align(

            alignment: Alignment.bottomRight,
            child: RaisedButton(
              padding: EdgeInsets.fromLTRB(25, 16, 25, 16),
              child: Text("Save", style: TextStyle(color: Colors.white),),
              color: Colors.red,
              onPressed: () {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          )
        ],
      ),
    );
  }
}

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

    bool res = await _dataManager.checkEmail(email);
    if(res) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return SignUp(email: email);
          }
      ));
    }
  }
}