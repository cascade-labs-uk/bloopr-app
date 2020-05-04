import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/backend.dart';
import 'package:blooprtest/profile_pages/user_profile_page.dart';
import 'package:blooprtest/config.dart';

class AddFriendsBar extends StatefulWidget {
  AddFriendsBar({this.key});

  final Key key;
  final BaseBackend backend = new Backend();

  @override
  _AddFriendsBarState createState() => _AddFriendsBarState();
}

class _AddFriendsBarState extends State<AddFriendsBar> {
  List<Widget> friends = [];
  List<DocumentSnapshot> friendDocuments = [];

  @override
  void initState() {
    super.initState();

    widget.backend.getDiscoverFriends(15).then((friendsSnapshot) {
      setState(() {
        friendDocuments= friendsSnapshot.documents;
      });
      for (int counter = 0; counter < friendsSnapshot.documents.length; counter++) {
        String friendFirebaseID = friendsSnapshot.documents[counter].documentID;
        String friendName = friendsSnapshot.documents[counter].data['nickname'];
        String profilePictureLocation = friendsSnapshot.documents[counter].data['profile picture URL'];
        Future<Uint8List> futureProfilePicture = widget.backend.getImageFromLocation(profilePictureLocation!=null?profilePictureLocation:Constants.DEFAULT_PROFILE_PICTURE_LOCATION);
        print(friendName);
        Widget newFriendWidget = new FriendWidget(
          firebaseID: friendFirebaseID,
          nickname: friendName,
          profilePicture: futureProfilePicture,
          key: UniqueKey(),
        );
        setState(() {
          friends.add(newFriendWidget);
        });
        print(friends);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: friendDocuments.map((document) => new FriendWidget(
        firebaseID: document.documentID,
        nickname: document.data['nickname'],
        profilePicture: widget.backend.getImageFromLocation(document.data['profile picture URL']),
        userDocument: document,
        key: UniqueKey(),
      )).toList(),
    );
  }
}

class FriendWidget extends StatefulWidget {
  FriendWidget({this.firebaseID, this.nickname, this.profilePicture, this.userDocument, this.key});

  final String firebaseID;
  final String nickname;
  final Future<Uint8List> profilePicture;
  final Key key;
  final DocumentSnapshot userDocument;

  @override
  _FriendWidgetState createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {

  Future openUserProfile(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(
      displayedUserFirestoreID: widget.firebaseID,
      displayedUserID: widget.userDocument.data['userID'],
      userDocument: widget.userDocument,
      )));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      key: ValueKey(widget.firebaseID),
      future: widget.profilePicture,
      builder: (context, snapshot) {
        Widget child;
        if(snapshot.hasData && snapshot.data != null) {
          child = Container(
            height: 80,
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Constants.OUTLINE_COLOR,
                          width: 0.5
                      ),
                      borderRadius: BorderRadius.circular(100)
                  ),
                  child: ClipRRect(
                    child: Image.memory(
                      snapshot.data,
                      width: 70,
                      height: 70,
                    ),
                    borderRadius: BorderRadius.circular(35.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,5,0,0),
                  child: Text(
                    widget.nickname,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          );
        } else {
          child = Container(
            height: 80,
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Constants.OUTLINE_COLOR,
                          width: 0.5
                      ),
                      borderRadius: BorderRadius.circular(100)
                  ),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/profile_image_placeholder.png',
                      width: 70,
                      height: 70,
                    ),
                    borderRadius: BorderRadius.circular(35.0),
                  ),
                ),
                Text(
                  widget.nickname,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                ),
              ],
            ),
          );
        }
        return GestureDetector(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5.0,0,5.0,0),
            child: child,
          ),
          onTap: () {
            openUserProfile(context);
          },
        );
      },
    );
  }
}


//class FriendWidget extends StatelessWidget {
//  FriendWidget({this.firebaseID, this.nickname, this.profilePicture});
//
//  final String firebaseID;
//  final String nickname;
//  final Future<Uint8List> profilePicture;
//
//  @override
//  Widget build(BuildContext context) {
//    return FutureBuilder(
//      future: profilePicture,
//      builder: (context, snapshot) {
//        Widget child;
//        if(snapshot.hasData) {
//          child = Container(
//            height: 50,
//            width: 50,
//            child: Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                ClipRRect(
//                  child: Image.memory(
//                    snapshot.data,
//                    width: 36.0,
//                    height: 36.0,
//                  ),
//                  borderRadius: BorderRadius.circular(18.0),
//                ),
//                Text(nickname),
//              ],
//            ),
//          );
//        } else {
//          child = Container(
//            height: 50,
//            width: 50,
//            child: Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                ClipRRect(
//                  child: Image.asset(
//                    'assets/profile_image_placeholder.png',
//                    width: 36.0,
//                    height: 36.0,
//                  ),
//                  borderRadius: BorderRadius.circular(18.0),
//                ),
//                Text(nickname),
//              ],
//            ),
//          );
//        }
//        return child;
//      },
//    );
//  }
//}

