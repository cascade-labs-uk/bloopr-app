import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  ErrorPage({this.toHomePage});

  final VoidCallback toHomePage;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Text("Uh oh - an error occured"),
            RaisedButton(
              child: Text("back to home"),
              onPressed: toHomePage,
            )
          ],
        ),
      ),
    );
  }
}
