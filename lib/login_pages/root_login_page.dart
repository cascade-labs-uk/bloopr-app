//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blooprtest/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/login_pages/forgot_password_page.dart';
import 'package:blooprtest/login_pages/create_account_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormType {
  login,
  register,
  forgotPassword
}

class _LoginPageState extends State<LoginPage> {

  // TODO: remember to use Form.of() method with more complex nested tree
  final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _confirmPassword;
  FormType _formType = FormType.login;

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
        String userId = await widget.auth.signInWithEmailAndPassword(_email, _password);
        widget.onSignedIn();
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Center(child: CreateAccountPage(onSignedIn: widget.onSignedIn, auth: widget.auth))));
  }

  void moveToForgotPassword() {
    formKey.currentState.reset();
    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage(auth: widget.auth,)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  children: buildInputs() + buildSubmitButtons(),
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
      SizedBox(height: 150,),
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
              color: Constants.INACTIVE_COLOR_LIGHT,
            ),
          ),
          validator: (value) => value.isEmpty ? 'Email cannot be empty' : null,
          onSaved: (value) => _email = value,
        ),
      ),
      SizedBox(height: 30,),
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
            labelText: 'Password',
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          validator: (value) => value.isEmpty ? 'Password cannot be empty' : null,
          obscureText: true,
          onSaved: (value) => _password = value,
        ),
      ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: FlatButton(
                child: Text(
                  'Forgot Passsword?',
                  style: Constants.TEXT_STYLE_HINT_LIGHT,
                ),
                onPressed: moveToForgotPassword,
              ),
            ),
          ),
        ],
      ),
      Spacer(),
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
                  "Login",
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
        child: Text(
          'Create Account',
          style: Constants.TEXT_STYLE_HINT_DARK,
        ),
        onPressed: moveToRegister,
      ),
    ];
  }
}