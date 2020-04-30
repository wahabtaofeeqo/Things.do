import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mytodo/database.dart';
import 'package:mytodo/dialog.dart';
import 'package:mytodo/home.dart';
import 'package:mytodo/session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'account.dart';
import 'consts.dart';


class Welcome extends StatelessWidget {

  final String title;
  final manager = SessionManager.getInstance();

  Welcome({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Container(
              child: ListView(
                children: <Widget>[
                  Image.asset('assets/images/bg.jpg', fit: BoxFit.cover, height: 300,),
                  TextSection(),
                  ButtonSection(),
                  BottomSection(),
                ],
              )
          );
        },
      ),
    );
  }
}

// The WelcomeScene TextSection
class TextSection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(Constants.padding),
          child: Text(
            "Keep Track of Your Tasks",
            style: Theme.of(context).textTheme.title,
            textAlign: TextAlign.center,
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 0, 12.0, 16.0),
          child: Text(
            "Join The Community of people using Things.do to organize their daily tasks.",
            style: Theme.of(context).textTheme.subtitle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// The WelcomeScene ButtonSection
class ButtonSection extends StatelessWidget {

  final _sessionManager = SessionManager.getInstance();
  final _dataManager = DataManager.getInstance();
  final GoogleSignIn _googleSignIn = new GoogleSignIn(scopes: ['email']);
  final facebookLogin = new FacebookLogin();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _googleLoginButton(context),
        _facebookLoginButton(context),
        _emailLoginButton(context)
      ],
    );
  }

  // Google Login Button
  Widget _googleLoginButton(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 16.0, left: 18.0, right: 18.0),
        child: RaisedButton(
          color: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: <Widget>[
                Image.asset(
                  'assets/images/google.jpg',
                  width: 25,
                  height: 25,
                ),
                Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          Text("Continue with Google", style: TextStyle(fontSize: 16.0, color: Colors.white),),
                          Text("Secured Login", style: TextStyle(fontSize: 12.0, color: Colors.grey[200]),)
                        ],
                      ),
                    )
                )
              ],
            ),
          ),
          onPressed: () {
            _googleLogin(context);
          },
        )
    );
  }

  Widget _facebookLoginButton(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 16.0, left: 18.0, right: 18.0),
        child: RaisedButton(
          color: Colors.blue[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: <Widget>[
                Image.asset(
                  'assets/images/fb1.jpg',
                  width: 25,
                  height: 25,
                ),
                Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          Text("Continue with Facebook", style: TextStyle(fontSize: 16.0, color: Colors.white),),
                          Text("We'll never post on your behave", style: TextStyle(fontSize: 12.0, color: Colors.grey[200]),)
                        ],
                      ),
                    )
                )
              ],
            ),
          ),
          onPressed: () {
            _facebookLogin();
          },
        )
    );
  }

  Widget _emailLoginButton(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 16.0, left: 18.0, right: 18.0, bottom: 16.0),
        child: OutlineButton(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          borderSide: BorderSide(
            width: 1,
            color: Colors.black,
            style: BorderStyle.solid,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.email),
                Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          Text("Continue with Email", style: TextStyle(fontSize: 16.0, color: Colors.black),),
                        ],
                      ),
                    )
                )
              ],
            ),
          ),
          onPressed: () async {
            var session = SessionManager.getInstance();
            print(await session.isFirstTime());
            showDialog(context: context, builder: (context) => EmailDialogWidget());
          },
        )
    );
  }

  _googleLogin(BuildContext context) async {
    try {
      await _googleSignIn.signIn();
      bool res = await _dataManager.checkEmail(_googleSignIn.currentUser.email);
      if(res) {
        //TODO:: save to firebase
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return SignUp(email: _googleSignIn.currentUser.email);
            }
        ));
      }
      else {
        print("Email Exist");
      }
    }
    catch(err) {
      print("Cancled");
    }
  }

  void _facebookLogin() async {
    try {
      var facebookLoginResult = await facebookLogin.logInWithReadPermissions(['email']);

      switch (facebookLoginResult.status) {
        case FacebookLoginStatus.error:
          print("Error");
          break;
        case FacebookLoginStatus.cancelledByUser:
          print("CancelledByUser");
          break;
        case FacebookLoginStatus.loggedIn:
          print("LoggedIn");
          break;
      }
    }
    catch(err) {
      print(err);
    }
  }
}


// WelcomeScene Bottom
class BottomSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 0.0),
            child: GestureDetector(
              child: Text("Why do i need to create an account?",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              onTap: () {
                showModalBottomSheet(context: context, builder: (builder) {
                  return Container(
                      height: 360,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              child: Text(
                                "You shoul create an account because: ",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.center,
                              ),

                              padding: EdgeInsets.only(top: 16.0),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 18),
                              child: ListTile(
                                title: Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: Icon(Icons.desktop_mac),
                                    ),

                                    Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            "Sync Your tasks accross devices",
                                            style: TextStyle(color: Colors.grey, fontSize: 15.0),
                                            textAlign: TextAlign.justify,
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(top: 18),
                              child: ListTile(
                                title: Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: Icon(Icons.cloud),
                                    ),

                                    Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            "Backup your data(tasks) in a secured & private cloud",
                                            style: TextStyle(color: Colors.grey, fontSize: 15.0),
                                            textAlign: TextAlign.justify,
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(top: 18),
                              child: ListTile(
                                title: Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: Icon(Icons.people),
                                    ),

                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 16.0),
                                        child: Text(
                                          "Collaborate with loved ones, family or colleagues",
                                          style: TextStyle(color: Colors.grey, fontSize: 15.0),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(top: 20.0),
                              width: MediaQuery.of(context).size.width,
                              height: 45,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                color: Colors.blue,
                                child: Text("OK, got it", style: TextStyle(color: Colors.white),),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            )

                          ],
                        ),
                      )
                  );
                });
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "By using Things.do, you accept our Terms of Use and Privacy Policy",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black26),
            ),
          ),
        ],
      ),
    );
  }
}