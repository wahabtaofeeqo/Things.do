import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytodo/data/firebase_records.dart';
import 'package:mytodo/database.dart';
import 'package:mytodo/home.dart';
import 'package:mytodo/data/session.dart';
import 'package:mytodo/user.dart';
import 'package:mytodo/utils.dart';

class LoginScreen extends StatefulWidget {

  final String email;

  LoginScreen(this.email);

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {

  bool _isLoading;

  final _session = SessionManager.getInstance();
  final _firebase = FirebaseRecords();
  final _dataManager = DataManager.getInstance();

  var _emailController;
  var _passController;

  @override
  void initState() {
    super.initState();

    _isLoading = false;
    _emailController = new TextEditingController(text: widget.email);
    _passController = new TextEditingController();
  }

  @override
  dispose() {
    super.dispose();

    _emailController.dispose();
    _passController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        padding: EdgeInsets.all(18),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
              child: Text("Welcome Back!.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,),
            ),

            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 30),
              child: Text("Login to your account and load your Todos",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,),
            ),

            TextFormField(
              controller: _emailController,
              enabled: (widget.email != null) ? false: true,
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: TextFormField(
                controller: _passController,
                decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    focusColor: Colors.transparent
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 18),
              child: RaisedButton(

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: Colors.deepOrange,
                child: Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Text("Login", style: TextStyle(color: Colors.white),),
                ),
                onPressed: (_isLoading) ? null : _onClickLoginButton,
              ),
            )
          ],
        ),
      )
    );
  }

  Future<Null> _submitDialog(BuildContext context) async {
    return await showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: CircularProgressIndicator(),
              )
            ],
          );
        });
  }

  _onClickLoginButton() async {

    if(_emailController.text.toString().isEmpty && _passController.text == "") return;

    setState(() { _isLoading = true; });
    _submitDialog(context);

    var data = await _firebase.login(_emailController.text.toString().trim(), null);

    if(data != null) {
      if(data['password'] == _passController.text.toString().trim()) {
        Utils.showMessage("Account claimed. Welcome back", context);

        // To local Database
        await _dataManager.saveUser(User.fromMap(data));

        // To share preferences
        await _session.setEmail(_emailController.toString().trim());

        Navigator.of(context).popUntil(ModalRoute.withName("/")); // To prevent back button from coming to this page again
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (context) => HomePage(title: "Home",)
        ));
      }
      else {
        Utils.showMessage("Password not correct!", context);
      }
    }
    else {
      Navigator.of(context).pop();
      Utils.showMessage("Email not found.", context);
    }

    setState(() { _isLoading = false; });
  }
}