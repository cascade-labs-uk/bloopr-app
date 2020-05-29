import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blooprtest/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:blooprtest/config.dart';

class CreateAccountPage extends StatefulWidget {
  CreateAccountPage({this.onSignedIn, this.auth});

  final VoidCallback onSignedIn;
  final BaseAuth auth;

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {

  final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _confirmPassword;

  void openPolicyDisclaimer() {
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text("EULA"),
          content: Container(
              width: MediaQuery.of(context).size.width * 0.90,
              height: MediaQuery.of(context).size.height * 0.90,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                          Constants.EULA_AGREEMENT_TEXT
                      ),
                    ),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(
                          color: Constants.DARK_TEXT,
                          width: 0.5,
                        )
                    ),
                    elevation: 0,
                    color: Constants.BACKGROUND_COLOR,
                    child: Text('By clicking you agree to the above policy'),
                    onPressed: () {
                      Navigator.pop(context);
                      validateAndSubmit();
                    },
                  )
                ],
              )
          ),
        )
    );
  }

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
        String userId = await widget.auth.createUserWithEmailAndPassword(_email, _password);
        widget.onSignedIn();
      } catch (e) {
        print('Error: $e');
      }
    }
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
      SizedBox(height: 90,),
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
              labelText: 'Enter email',
              labelStyle: TextStyle(
                color: Constants.INACTIVE_COLOR_LIGHT,
              )
          ),
          validator: (value) => value.isEmpty ? 'email cannot be empty' : null,
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
              labelText: 'Enter password',
              labelStyle: TextStyle(
                color: Constants.INACTIVE_COLOR_LIGHT,
              )
          ),
          validator: (value) => value.isEmpty ? 'password cannot be empty' : null,
          obscureText: true,
          onSaved: (value) => _password = value,
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
              labelText: 'Confirm password',
              labelStyle: TextStyle(
                color: Constants.INACTIVE_COLOR_LIGHT,
              )
          ),
          validator: (value) => value.isEmpty ? 'please retype your password' : null,
          obscureText: true,
          onSaved: (value) => _confirmPassword = value,

        ),
      ),
    ];
  }

  List<Widget> buildButtons() {
    return [
      Spacer(),
      SizedBox(
        height: 60.0,
        width: 220,
        child: ButtonTheme(
          buttonColor: Constants.BACKGROUND_COLOR,
          minWidth: 220,
          child: RaisedButton(
            elevation: 0,
            onPressed: openPolicyDisclaimer,
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
                  "Create account",
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
          'Have an account? Login',
          style: Constants.TEXT_STYLE_HINT_DARK,
        ),
        onPressed: () {
          Navigator.pop(context); // page is pushed onto the navigation stack so it can be removed by simply popping it off the stack
        },
      )
    ];
  }
}
