import 'package:blooprtest/backend.dart';
import 'package:blooprtest/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SeeFollowList extends StatefulWidget {
  SeeFollowList({this.displayedUserFirebaseID});

  final String displayedUserFirebaseID;
  final BaseBackend backend = new Backend();

  @override
  _SeeFollowListState createState() => _SeeFollowListState();
}

enum ListType {
  following,
  followers
}

class _SeeFollowListState extends State<SeeFollowList> {
  List<DocumentSnapshot> followerDocuments = [];
  List<DocumentSnapshot> followingDocuments = [];

  @override
  void initState() {
    super.initState();

    // TODO: backend.getFollowing(widget.displayedUserID).then...
    widget.backend.getUserFollowers(widget.displayedUserFirebaseID).then((querySnapshot) {
      setState(() {
        followerDocuments = querySnapshot.documents;
      });
    });

    widget.backend.getUserFollowing(widget.displayedUserFirebaseID).then((querySnapshot) {
      setState(() {
        followingDocuments = querySnapshot.documents;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Constants.SECONDARY_COLOR,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 22.5,
              color: Constants.INACTIVE_COLOR_DARK,
            ),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text("Username", style: Constants.TEXT_STYLE_HEADER_DARK,),
          bottom: TabBar(
            labelStyle: Constants.TEXT_STYLE_HEADER_HIGHLIGHT,
            unselectedLabelStyle: Constants.TEXT_STYLE_HEADER_DARK,
            indicatorColor: Constants.INACTIVE_COLOR_DARK,
            tabs: <Widget>[
              Tab(
                child: Text(
                  'Followers',
                  style: Constants.TEXT_STYLE_HEADER_DARK,

                )
              ),
              Tab(
                child: Text(
                  'Following',
                  style: Constants.TEXT_STYLE_HEADER_DARK,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Container(
              child: ListView(
                children: followerDocuments.map((document) => FollowingCard(
                    documentSnapshot:document,
                    following: false,
                    key: UniqueKey()
                )).toList()
              ),
            ),
            Container(
              child: ListView(
                children: followingDocuments.map((document) => FollowingCard(
                  documentSnapshot:document,
                  following: true,
                  key: UniqueKey()
                )).toList()
              ),
            )
          ],
        )
      ),
    );
  }
}

class FollowingCard extends StatefulWidget {
  FollowingCard({this.documentSnapshot, this.following, this.key});

  final DocumentSnapshot documentSnapshot;
  final bool following;
  final Key key;
  final BaseBackend backend = Backend();

  @override
  _followingCardState createState() => _followingCardState();
}

class _followingCardState extends State<FollowingCard> {

  bool following;

  void toggleFollow(String userFirestoreID) {
    if(following) {
      widget.backend.unfollow(userFirestoreID);
    } else {
      widget.backend.addFollow(userFirestoreID);
    }
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      following = false;
    });

    updateFollowing();
  }

  void updateFollowing() {
    widget.backend.amFollowing(widget.documentSnapshot.data["userFirestoreID"]).then((amFollowing) {
      setState(() {
        following = amFollowing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: widget.key,
      padding: const EdgeInsets.fromLTRB(0, 8.5, 0, 8.5),
      child: ListTile(
        trailing: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(
                color: following?Constants.DARK_TEXT:Constants.HIGHLIGHT_COLOR,
                width: 0.5,
              )
          ),
          elevation: 0,
          color: following?Constants.LIGHT_TEXT:Constants.HIGHLIGHT_COLOR,
          child: following?Text('Unfollow', style: Constants.TEXT_STYLE_HINT_BLACK,):Text('Follow', style: Constants.TEXT_STYLE_HINT_LIGHT,),
          onPressed: () {
            toggleFollow(widget.documentSnapshot.data['userFirestoreID']);
            setState(() {
              following = !following;
            });
          },
        ),
        leading: FutureBuilder(
          future: widget.backend.getImageFromLocation(widget.documentSnapshot.data['user profile picture URL']),
          builder: (context, snapshot) {
            Widget displayedImage;
            if(snapshot.hasData) {
              displayedImage = Image.memory(
                snapshot.data,
                height: 70,
                width: 70,
              );
            } else {
              displayedImage = Image.asset(
                'assets/profile_image_placeholder.png',
                height: 70,
                width: 70,
              );
            }

            return ClipRRect(
              child: displayedImage,
              borderRadius: BorderRadius.circular(35.0),
            );
          },
        ),
        title: Text(
          widget.documentSnapshot.data['user nickname'],
          style: Constants.TEXT_STYLE_CAPTION_DARK,
        ),
      ),
    );
  }
}

