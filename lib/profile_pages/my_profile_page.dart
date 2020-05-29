import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/profile_pages/base_profile_page.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/backend.dart';
import 'package:blooprtest/auth.dart';

class MyProfilePage extends StatefulWidget {
  MyProfilePage({this.toDiscoverPage, this.toSwipePage, this.auth, this.onSignedOut});

  final VoidCallback toSwipePage;
  final VoidCallback toDiscoverPage;
  final VoidCallback onSignedOut;
  final Auth auth;

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {

  String currentUserFirestoreID;
  BaseBackend backend = new Backend();
  String currentUserID;
  DocumentSnapshot currentUserDocument;

  void initState() {
    super.initState();

    backend.getOwnFirestoreUserID().then((userID) {
      backend.getUser(userID).then((userDocument) {
        setState(() {
          currentUserDocument = userDocument;
        });
      });
      setState(() {
        currentUserFirestoreID = userID; //we get the authenticated user's Firestore ID so we can retrieve their profile data
      });
    });

    backend.getOwnUserID().then((userID) {
      setState(() {
        currentUserID = userID;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // if we've retrieved the current user's ID we display the base profile page, otherwise we display a loading icon
            currentUserFirestoreID==null||currentUserID==null||currentUserDocument==null?
            Expanded(
                child: Center(child: CircularProgressIndicator())
            ):
            BaseProfilePage(
              displayedUserFirestoreID: currentUserFirestoreID,
              displayedUserID: currentUserID,
              userDocument: currentUserDocument,
              isOwnProfile: true,
              auth: widget.auth,
              onSignedOut: widget.onSignedOut
            ),
            Container(
              color: Constants.OUTLINE_COLOR,
              width: double.infinity,
              height: 0.5,
            ),
            navigationBar()
          ],
        ),
      ),
    );
  }

  // returns  the general navigation bar
  Widget navigationBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      color: Constants.SECONDARY_COLOR,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Spacer(),
          IconButton(
            icon: Icon(Constants.EXPLORE_PAGE_ICON, size: 32.0,),
            color: Constants.INACTIVE_COLOR_DARK,
            onPressed: widget.toDiscoverPage,
          ),
          Spacer(),
          IconButton(
            icon: Icon(Constants.SWIPE_PAGE_INACTIVE_ICON, size: 35,),
            onPressed: widget.toSwipePage,
          ),
          Spacer(),
          IconButton(
              icon: Icon(Constants.PROFILE_PAGE_ACTIVE_ICON, size: 40.0,),
              onPressed: (){}
          ),
          Spacer(),
        ],
      ),
    );
  }
}


