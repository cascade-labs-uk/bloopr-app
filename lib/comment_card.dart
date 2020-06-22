import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/backend.dart';

class CommentCard extends StatefulWidget {
  CommentCard({this.parentPostID, this.commentDocument, this.key});

  final DocumentSnapshot commentDocument;
  final String parentPostID;
  final BaseBackend backend = new Backend();
  final Key key;

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  String commentText;
  String commenterNickname;
  String commentID;
  bool liked = false;
  int likeNumber;

  void changeLikedStatus() {
    if(liked == true) {
      widget.backend.addCommentLike(widget.parentPostID, commentID);
    } else {
      widget.backend.removeCommentLike(widget.parentPostID, commentID);
    }

    setState(() {
      liked = !liked;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if(widget.commentDocument.data['text'] != null) {
        commentText = widget.commentDocument.data['text'];
      } else {
        commentText = 'Error 404';
      }
      if(widget.commentDocument.data['commenter name'] != null) {
        commenterNickname = widget.commentDocument.data['commenter name'];
      } else {
        commenterNickname = 'Error 404';
      }
      commentID = widget.commentDocument.documentID;
    });

    isLiked();
  }

  void isLiked() {
    if(widget.commentDocument.data['likes'] == null) {
      setState(() {
        liked = false;
      });
    } else if (widget.commentDocument.data['likes'].length == 0) {
      setState(() {
        liked=false;
      });
    } else {
      widget.backend.getOwnUserID().then((userID) {
        if(widget.commentDocument.data['likes'].contains(userID)) {
          setState(() {
            liked=true;
          });
        } else {
          setState(() {
            liked=false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: widget.key,
      elevation: 0,
      color: Constants.BACKGROUND_COLOR,
      borderOnForeground: false,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              commenterNickname,
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text(
                    commentText,
                    overflow: TextOverflow.clip,
                    style: Constants.TEXT_STYLE_DARK,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  color: liked ? Constants.HIGHLIGHT_COLOR: Constants.SECONDARY_COLOR,
                  onPressed: changeLikedStatus,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
