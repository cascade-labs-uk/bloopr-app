import 'package:blooprtest/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/upload_pages/upload_profile_picture.dart';
import 'package:blooprtest/profile_pages/see_follow_list.dart';
import 'package:blooprtest/profile_pages/edit_profile_page.dart';
import 'package:blooprtest/settings_pages/main_settings_page.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/auth.dart';

class ProfilePageHeader extends StatefulWidget {
  ProfilePageHeader({this.userID, this.userDocument, this.isOwnProfile, this.auth, this.onSignedOut});

  final DocumentSnapshot userDocument;
  final String userID;
  final bool isOwnProfile;
  final BaseBackend backend = new Backend();
  final Auth auth;
  final VoidCallback onSignedOut;

  @override
  _ProfilePageHeaderState createState() => _ProfilePageHeaderState();
}

class _ProfilePageHeaderState extends State<ProfilePageHeader> {
  bool following;

  Future openUploadProfilePicture(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => UploadProfilePicture()));
  }

  Future openFollowList(context) async {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => SeeFollowList(displayedUserFirebaseID: widget.userDocument.documentID,))
    );
  }

  Future openEditProfile(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(firestoreID: widget.userID,)));
  }

  Future openSettings(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(
      auth: widget.auth,
      onSignedOut: widget.onSignedOut,
      userFirestoreID: widget.userDocument.documentID
    )));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      following = false;
    });
    widget.backend.getFollowingFromFirestoreID(widget.userDocument.documentID).then((followingSnapshot) {
      if(followingSnapshot.documents.length > 0) {
        setState(() {
          following = true;
        });
      } else {
        setState(() {
          following = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.BACKGROUND_COLOR,
      child: Column(
        children: <Widget>[
          Visibility(
            visible:widget.isOwnProfile,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Constants.INACTIVE_COLOR_DARK,
                    size: 30.0,
                  ),
                  onPressed: () {
                    openSettings(context);
                  },
                )
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Constants.OUTLINE_COLOR,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(100)
              ),
              child: ClipRRect(
                child: ProfilePicture(widget.userID),
                borderRadius: BorderRadius.circular(75.0),
              ),
            ),
            onTap: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) =>
                      CupertinoActionSheet(
                        title: Text(
                          "Change Profile Picture",
                          style: Constants.ACTION_SHEET_TITLE,
                        ),
                        actions: <Widget>[
                          CupertinoActionSheetAction(
                            child: Text(
                              "Remove Current Photo",
                              style: Constants.ACTION_SHEET_TEXT,
                            ),
                            onPressed: () {
                              // Action to share post
                              Navigator.pop(context);
                            },
                          ),
                          CupertinoActionSheetAction(
                            child: Text(
                              "Choose From Library",
                              style: Constants.ACTION_SHEET_TEXT,
                            ),
                            onPressed: () {
                              // Action to save post
                              Navigator.pop(context);
                            },
                          ),
                          CupertinoActionSheetAction(
                            child: Text(
                              "Take a Photo",
                              style: Constants.ACTION_SHEET_TEXT,
                            ),
                            onPressed: () {
                              // Action to share post
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          child: Text(
                            "Cancel",
                            style: Constants.ACTION_SHEET_TEXT,
                          ),
                          onPressed: () {
                            Navigator.pop(context, 'Cancel');
                          },
                        ),
                      ),
                );

//              if(widget.isOwnProfile) {
//                openUploadProfilePicture(context);
//              }
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,12.0,0,12.0),
            child: Text(
              widget.userDocument.data['nickname'],
              style: Constants.TEXT_STYLE_HEADER_DARK,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0,0.0,0.0,12.0),
            child: Row(
              children: <Widget>[
                Spacer(flex: 5,),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => CustomDialog(
                        title: "Success",
                        description:
                        "Gain swipes when people swipe right on your posts!",
                        buttonText: "Ok",
                      ),
                    );
                  },
                  child: Column(
                    children: <Widget>[
                      Text(
                        getUserSwipes(),
                        style: Constants.TEXT_STYLE_LARGE_NUMBERS_DARK,
                      ),
                      Text(
                        'Swipes',
                        style: Constants.TEXT_STYLE_HINT_DARK,
                      )
                    ],
                  ),
                ),
                Spacer(flex: 2,),
                GestureDetector(
                  onTap: () {
                    openFollowList(context);
                  },
                  child: Column(
                    children: <Widget>[
                      Text(
                        getUserFollowers(),
                        style: Constants.TEXT_STYLE_LARGE_NUMBERS_DARK,
                      ),
                      Text(
                        'Followers',
                        style: Constants.TEXT_STYLE_HINT_DARK,
                      )
                    ],
                  ),
                ),
                Spacer(flex: 2,),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      child: AlertDialog(
                        content: Image.asset(
                          'assets/profile_image_placeholder.png',
                          height: 100,
                          width: 100,
                        ),
                        elevation: 0,
                        actions: <Widget>[
                          FlatButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.5),
                        ),
                      ),
                      barrierDismissible: true,
                    );
                  },
                  child: Column(
                        children: <Widget>[
                          Text(
                            getUserGloves(),
                            style: Constants.TEXT_STYLE_LARGE_NUMBERS_DARK,
                          ),
                          Text(
                            'Gloves',
                            style: Constants.TEXT_STYLE_HINT_DARK,
                          )
                        ],
                      ),
                ),
                Spacer(flex: 5,),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0,8.0,20.0,0.0),
            child: Text(
              widget.userDocument.data['user bio'],
              style: Constants.TEXT_STYLE_DARK,
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
            child: widget.isOwnProfile?
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: Constants.GREY_TEXT,
                    width: 1.25,
                  )
                ),

                color: Constants.BACKGROUND_COLOR,
                child: Text('Edit Profile'),
                onPressed: () {
                  openEditProfile(context);
                },
              )
            :RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: Constants.DARK_TEXT,
                    width: 0.5,
                  )
              ),
              elevation: 0,
              color: Constants.BACKGROUND_COLOR,
              child: following?Text('unfollow'):Text('follow'),
              onPressed: () {
                if(following) {
                  widget.backend.unfollow(widget.userDocument.documentID);
                  setState(() {
                    following = false;
                  });
                } else {
                  widget.backend.addFollow(widget.userDocument.documentID);
                  setState(() {
                    following = true;
                  });
                }
              },
            )
          )
        ],
      ),
    );
  }

  FutureBuilder ProfilePicture(String userID) {
    return FutureBuilder(
      future: widget.backend.getProfilePicture(userID),
      builder: (context, snapshot) {
        Widget displayed;
        if(snapshot.hasData && !snapshot.hasError) {
          if(snapshot.data != null) {
            displayed = Image.memory(
              snapshot.data,
              height: 150,
              width: 150,
            );
          } else {
            displayed = Image.asset(
              'assets/profile_image_placeholder.png',
              height: 150,
              width: 150,
            );
          }
        } else {
          displayed = Image.asset(
            'assets/profile_image_placeholder.png',
            height: 150,
            width: 150,
          );
        }

        return displayed;
      },
    );
  }

  String getUserFollowers() {
    if(widget.userDocument['follower number'] == null) {
      return "0";
    } else if (widget.userDocument['follower number'] > 999) {
      int thousands = (widget.userDocument['follower number']/1000).floor();
      String text = thousands.toString() + "k";
      return text;
    } else {
      return widget.userDocument['follower number'].toString();
    }
  }

  String getUserGloves() {
    if(widget.userDocument['gloves'] == null) {
      return "0";
    } else if (widget.userDocument['gloves'] > 999) {
      int thousands = (widget.userDocument['gloves']/1000).floor();
      String text = thousands.toString() + "k";
      return text;
    } else {
      return widget.userDocument['gloves'].toString();
    }
  }

  String getUserSwipes() {
    if(widget.userDocument['right swipes'] == null) {
      return "0";
    } else if (widget.userDocument['right swipes'] > 999) {
      int thousands = (widget.userDocument['right swipes']/1000).floor();
      String text = thousands.toString() + "k";
      return text;
    } else {
      return widget.userDocument['right swipes'].toString();
    }
  }
}








class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,// To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(top: 35.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
              SizedBox(
                height: 0.3,
                width: MediaQuery.of(context).size.width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Constants.OUTLINE_COLOR,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: FlatButton(
                  color: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 135, vertical: 0),
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: Container(
            height: 200.0,
            color: Colors.transparent,
            child: new Container(
                decoration: new BoxDecoration(
                    color: Colors.green,
                    borderRadius: new BorderRadius.all(
                        Radius.circular(10)
                    )
                ),
                child: new Center(
                  child: new Text("Display GIF or Image"),
                )
            ),
          ),
        ),
      ],
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}

