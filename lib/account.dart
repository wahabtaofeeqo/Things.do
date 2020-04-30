import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytodo/database.dart';
import 'package:mytodo/home.dart';
import 'package:mytodo/session.dart';
import 'package:mytodo/user.dart';

class SignUp extends StatelessWidget {

  final String email;
  SignUp({@required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Welcome to Things.do"),
      ),

      body: SignUpWidget(email: email,),
    );
  }
}

class SignUpWidget extends StatefulWidget {

  final String email;
  final _formKey = GlobalKey<FormState>();
  final _manager = DataManager.getInstance();
  final _session = SessionManager.getInstance();

  SignUpWidget({@required this.email});

  @override
  State<StatefulWidget> createState() {
    return _SignUpWidgetState();
  }
}

class _SignUpWidgetState extends State<SignUpWidget> {

  var _emailController = new TextEditingController();
  var _nameController  = new TextEditingController();
  var _passController  = new TextEditingController();
  bool _toggle = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      child: Form(
        key: widget._formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            Hero(
              tag: "Hero",
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 48.0,
                  child: Image.asset('assets/images/flutter_icon.png'),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 16.0, top: 50.0),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    hintText: "Email",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Colors.black26, width: 1)
                    ),
                    border: OutlineInputBorder(),
                ),
                validator: (val) {
                  return _validate(val);
                },
              ),
            ),

            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: "Name",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Colors.black26, width: 1)
                    ),
                    border: OutlineInputBorder()
                ),
                validator: (val) {
                  return _validate(val);
                },
              ),
            ),

            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                obscureText: _toggle,
                decoration: InputDecoration(
                    hintText: "Choose Password",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Colors.black26, width: 1)
                    ),
                    border: OutlineInputBorder(),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _toggle = !_toggle;
                      });
                    },
                    child: Icon(Icons.remove_red_eye,),
                  )
                ),
                validator: (val) {
                  return _validate(val);
                },
              ),
            ),

            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Create Account", style: TextStyle(color: Colors.white),),
              ),
              onPressed: () {
                if(widget._formKey.currentState.validate()) {
                  _saveUser();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  _validate(String val) {
    return (val.isEmpty) ? "Enter valid data" : null;
  }

  _saveUser() {
    var user = new User(name: _nameController.text, email: _emailController.text, password: _passController.text);
    widget._manager.saveUser(user);
    widget._session.setIsFirstTime(false);

    Navigator.popUntil(context, ModalRoute.withName("/")); // Back to the WelcomeScene
    Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return HomePage(title: "Home",);
            }
        )
    );
  }
}