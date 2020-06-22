import 'package:flutter/material.dart';
import 'package:blooprtest/profile_pages/base_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blooprtest/config.dart';

class UserProfilePage extends StatefulWidget {
  UserProfilePage({this.displayedUserID, this.displayedUserFirestoreID, this.userDocument});

  final String displayedUserFirestoreID;
  final String displayedUserID;
  final DocumentSnapshot userDocument;

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(git
        elevation: 0,
        backgroundColor: Constants.BACKGROUND_COLOR,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 22.5,
            color: Constants.INACTIVE_COLOR_DARK,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          BaseProfilePage(
            displayedUserFirestoreID: widget.displayedUserFirestoreID,
            displayedUserID: widget.displayedUserID,
            userDocument: widget.userDocument,
            isOwnProfile: false,
          ),
        ],
      ),
    );

  }
}
