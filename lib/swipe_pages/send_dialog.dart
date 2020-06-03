import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/backend.dart';
import 'dart:typed_data';

class SendDialog extends StatefulWidget {
  SendDialog({this.context, this.currentPostID});

  final BuildContext context;
  final BaseBackend backend = new Backend();
  final String currentPostID;

  @override
  _SendDialogState createState() => _SendDialogState();
}

class _SendDialogState extends State<SendDialog> {
  List<DocumentSnapshot> friendDocuments = [];

  @override
  void initState() {
    super.initState();
    widget.backend.getOwnFirestoreUserID().then((firestoreUserID) {
      widget.backend.getUserFollowers(firestoreUserID).then((followersSnapshot) {
        for(int counter = 0; counter < followersSnapshot.documents.length; counter++) {
          setState(() {
            friendDocuments.add(followersSnapshot.documents[counter]);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Send To Friends"),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.98,
        height: 90.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: friendDocuments.map((friendDocument) =>
            FriendWidget(
              firestoreID: friendDocument.data["user firestoreID"],
              nickname: friendDocument.data["user nickname"],
              profilePicture: widget.backend.getImageFromLocation(friendDocument.data["user profile picture URL"]),
              userDocument: friendDocument,
              backend: widget.backend,
              currentPostID: widget.currentPostID,
            )
          ).toList(),
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );
  }
}

class FriendWidget extends StatefulWidget {
  FriendWidget({this.firestoreID, this.nickname, this.profilePicture, this.userDocument, this.backend, this.currentPostID});

  final String firestoreID;
  final String nickname;
  final Future<Uint8List> profilePicture;
  final DocumentSnapshot userDocument;
  final BaseBackend backend;
  final String currentPostID;

  @override
  _FriendWidgetState createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {

  bool sent;

  @override
  void initState() {
    super.initState();

    sent=false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      key: ValueKey(widget.firestoreID),
      future: widget.profilePicture,
      builder: (context, snapshot) {
        Widget child;
        if(snapshot.hasData) {
          child = Container(
            height: 75,
            width: 75,
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
                  child: !sent?ClipRRect(
                    child: Image.memory(
                      snapshot.data,
                      width: 60,
                      height: 60,
                    ),
                    borderRadius: BorderRadius.circular(35.0),
                  ):Icon(
                    Icons.check,
                    size: 60,
                    color: Constants.HIGHLIGHT_COLOR,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,7.5,0,0),
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
            height: 75,
            width: 75,
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
                  child: !sent?ClipRRect(
                    child: Image.asset(
                      'assets/profile_image_placeholder.png',
                      width: 60,
                      height: 60,
                    ),
                    borderRadius: BorderRadius.circular(35.0),
                  ):Icon(
                    Icons.check,
                    size: 60,
                    color: Constants.HIGHLIGHT_COLOR,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,7.5,0,0),
                  child: Text(
                    widget.nickname,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return GestureDetector(
          key: widget.key,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,0),
            child: child,
          ),
          onTap: () {
            if(!sent) {
              widget.backend.sendMeme(widget.firestoreID, widget.currentPostID);
              print("send meme to ${widget.nickname}");
              setState(() {
                sent = true;
              });
            }
          },
        );
      },
    );
  }
}
