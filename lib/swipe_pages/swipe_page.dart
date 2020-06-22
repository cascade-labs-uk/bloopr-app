import 'package:flutter/material.dart';
import '../auth.dart';
import 'package:flutter/material.dart';
import 'cards_section_alignment.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/asset_management/my_flutter_app_icons.dart';
import 'package:blooprtest/asset_management/custom_icons_icons.dart';

class SwipePage extends StatefulWidget {
  SwipePage({this.auth, this.onSignedOut, this.toDiscoverPage, this.toMyProfilePage});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final VoidCallback toMyProfilePage;
  final VoidCallback toDiscoverPage;

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
//      appBar: AppBar(
//        elevation: 0.0,
//        centerTitle: true,
//        backgroundColor: Colors.grey[800],
//        leading: IconButton(
//            onPressed: () {}, icon: Icon(Icons.settings, color: Colors.grey)),
//        title: FlatButton(
//          child: Text('Log out'),
//          onPressed: _signOut,
//        ),
//        actions: <Widget>[
//          IconButton(
//              onPressed: () {},
//              icon: Icon(Icons.question_answer, color: Colors.grey)),
//        ],
//      ),
        backgroundColor: Constants.SECONDARY_COLOR,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CardsSectionAlignment(context),
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

  Widget navigationBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      color: Constants.SECONDARY_COLOR,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Spacer(),
          IconButton(
            icon: Icon(Constants.EXPLORE_PAGE_UNSELECTED_ICON, size: 27.5,),
            color: Constants.INACTIVE_COLOR_DARK,
            onPressed: widget.toDiscoverPage,
          ),
          Spacer(),
          IconButton(
            icon: Icon(Constants.SWIPE_PAGE_SELECTED_ICON, size: 32.0),
            onPressed: (){print("home pressed");},
          ),
          Spacer(),
          IconButton(
            icon: Icon(Constants.PROFILE_PAGE_UNSELECTED_ICON, size: 27.5),
            onPressed: () {
              print("go to profile page button pressed");
              widget.toMyProfilePage();
            }
          ),
          Spacer(),
        ],
      ),
    );
  }
}