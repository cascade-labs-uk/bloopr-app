import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blooprtest/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:blooprtest/config.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({this.auth});

  final BaseAuth auth;

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final formKey = new GlobalKey<FormState>();

  String _email;

  bool validateAndSave() {
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    if(validateAndSave()) {
      try {
        await widget.auth.resetPassword(_email);
        Fluttertoast.showToast(
          msg: 'reset email sent - check your inbox',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text('login page'),
//      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/login_page_background.png'), fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: buildInputs() + buildButtons(),
                ),
              ),
            ),
          )
        ],
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  List<Widget> buildInputs() {
    return [
      SizedBox(height: 160,),
      Theme(
        data: ThemeData(
          primaryColor: Constants.INACTIVE_COLOR_LIGHT,
          accentColor: Constants.INACTIVE_COLOR_LIGHT,
          hintColor: Constants.HIGHLIGHT_COLOR,
          cursorColor: Constants.INACTIVE_COLOR_LIGHT,
          textSelectionColor: Constants.INACTIVE_COLOR_LIGHT,
          inputDecorationTheme: InputDecorationTheme(
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Constants.INACTIVE_COLOR_LIGHT)
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Constants.INACTIVE_COLOR_LIGHT)
            ),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Constants.INACTIVE_COLOR_LIGHT)
            ),
          ),
        ),
        child: TextFormField(
          style: TextStyle(
              color: Constants.INACTIVE_COLOR_LIGHT
          ),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          validator: (value) => value.isEmpty ? 'Email cannot be empty' : null,
          onSaved: (value) => _email = value,
        ),
      ),
      Spacer()
    ];
  }

  List<Widget> buildButtons() {
    return [
      SizedBox(
        height: 60.0,
        width: 220,
        child: ButtonTheme(
          buttonColor: Constants.BACKGROUND_COLOR,
          minWidth: 220,
          child: RaisedButton(
            elevation: 0,
            onPressed: validateAndSubmit,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
            padding: EdgeInsets.all(0.0),
            child: Ink(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xff4EB9E8), Color(0xff6B95DE)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30.0)
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: 220.0, minHeight: 50.0),
                alignment: Alignment.center,
                child: Text(
                  "Send reset email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      FlatButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          'Back to login',
          style: Constants.TEXT_STYLE_HINT_DARK,
        ),
      )
    ];
  }
}
