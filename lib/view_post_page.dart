import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blooprtest/backend.dart';
import 'comment_card.dart';
import 'package:blooprtest/config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:blooprtest/comments_page.dart';
import 'package:blooprtest/profile_pages/user_profile_page.dart';

class ViewPostPage extends StatefulWidget {
  ViewPostPage({this.memeImage, this.memeDocument, this.isSavedPost = false, this.pageTitle, this.memeIndex, this.tag, this.isOwnPost=false});

  final Image memeImage;
  final DocumentSnapshot memeDocument;
  final bool isSavedPost;
  final String pageTitle;
  final int memeIndex;
  final String tag;
  final bool isOwnPost;
  final BaseBackend backend = new Backend();

  @override
  _ViewPostPageState createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  final formKey = new GlobalKey<FormState>();
  bool saved;
  bool reported = false;
  DocumentSnapshot userDocument;
  String heroTag;

  List<DocumentSnapshot> postComments = [];
  String userCommentText;

  Future openComments(context) async {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => CommentsPage(memeDocument: widget.memeDocument,))
    );
  }

  Future openUserProfile(context) async {
    if(userDocument == null) {
      widget.backend.getUser(widget.memeDocument.data['posterID']).then((document) => {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(
          displayedUserFirestoreID: document.documentID,
          displayedUserID: document.data['userID'],
          userDocument: document,
        )))
      });
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(
        displayedUserFirestoreID: userDocument.documentID,
        displayedUserID: userDocument.data['userID'],
        userDocument: userDocument,
      )));
    }

  }

  void unsavePost() {
    if(saved==false){
      widget.backend.unsavePost(widget.memeDocument.documentID);
    }
  }

  @override
  void initState() {
    super.initState();
    saved = widget.isSavedPost;
    if(widget.tag != null) {
      heroTag = widget.tag;
    } else if (widget.memeIndex != null) {
      heroTag = widget.memeDocument.documentID + widget.memeIndex.toString();
    } else {
      heroTag = widget.memeDocument.documentID;
    }

    widget.backend.getUser(widget.memeDocument.data['posterID']).then((document) {
      userDocument = document;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Constants.INACTIVE_COLOR_DARK, size: 22.5,),
            onPressed: () {
              if(widget.isSavedPost && !saved) {
                widget.backend.unsavePost(widget.memeDocument.documentID);
              }
              Navigator.pop(context);
            },
          ),
          title: Text(widget.pageTitle, style: Constants.TEXT_STYLE_HEADER_DARK,),
          backgroundColor: Constants.SECONDARY_COLOR,
        ),
        body: Container(
          color: Constants.BACKGROUND_COLOR,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(14,8,14,8),
                child: GestureDetector(
                  onTap: () {
                    openUserProfile(context);
                  },
                  child: Row( // TODO: add an onTap listener that opens the poster's profile page
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FutureBuilder(
                        future: widget.backend.getProfilePicture(widget.memeDocument.data['posterID']),
                        builder: (context, snapshot) {
                          Image displayedImage;
                          if(snapshot.hasData && snapshot.data != null) {
                            displayedImage = Image.memory(
                              snapshot.data,
                              height: 37,
                              width: 37,
                            );
                          } else {
                            displayedImage = Image.asset(
                              'assets/profile_image_placeholder.png',
                              height: 37,
                              width: 37,
                            );
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(18.5),
                            child: displayedImage,
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14.0,0,14.0,0),
                        child: Text(
                          widget.memeDocument.data['poster name'],
                          style: Constants.TEXT_STYLE_DARK,
                        ),
                      ),
                      Spacer(),
                      Visibility(
                        visible: widget.isSavedPost == false,
                        child: IconButton(
                          icon: Icon(Icons.more_horiz, color: Constants.DARK_TEXT, size: 22.5,),
                          onPressed: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) {
                                Widget finalWidget;
                                if(widget.isSavedPost) {
                                  finalWidget = CupertinoActionSheet(
                                    actions: [
                                      Container(
                                        child: CupertinoActionSheetAction(
                                          child: Text(
                                            reported?"Already Reported":"Report",
                                          ),
                                          onPressed: () {
                                            if(!reported) {
                                              widget.backend.reportMeme(widget.memeDocument.documentID);
                                              setState(() {
                                                reported = true;
                                              });
                                              Navigator.pop(context);
                                            }
                                          },
                                          isDestructiveAction: true,
                                        ),
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text(
                                          saved?"Unsave post":"Save Post",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            saved = !saved;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, 'Cancel');
                                      },
                                    ),
                                  );
                                } else if (widget.isOwnPost) {
                                  finalWidget = CupertinoActionSheet(
                                    actions: [
                                      Container(
                                        child: CupertinoActionSheetAction(
                                          child: Text(
                                            reported?"Already Reported":"Report",
                                          ),
                                          onPressed: () {
                                            if(!reported) {
                                              widget.backend.reportMeme(widget.memeDocument.documentID);
                                              setState(() {
                                                reported = true;
                                              });
                                              Navigator.pop(context);
                                            }
                                          },
                                          isDestructiveAction: true,
                                        ),
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text(
                                          "Delete Post",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        onPressed: () {
                                          widget.backend.removePost(widget.memeDocument.documentID);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, 'Cancel');
                                      },
                                    ),
                                  );
                                } else {
                                  finalWidget = CupertinoActionSheet(
                                    actions: [
                                      Container(
                                        child: CupertinoActionSheetAction(
                                          child: Text(
                                            reported?"Already Reported":"Report",
                                          ),
                                          onPressed: () {
                                            if(!reported) {
                                              widget.backend.reportMeme(widget.memeDocument.documentID);
                                              setState(() {
                                                reported = true;
                                              });
                                              Navigator.pop(context);
                                            }
                                          },
                                          isDestructiveAction: true,
                                        ),
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, 'Cancel');
                                      },
                                    ),
                                  );
                                }
                                return finalWidget;
                              }
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Hero(
                tag: widget.memeDocument.documentID,
                child: widget.memeImage,
//            child: Padding(
//              padding: const EdgeInsets.all(6.0),
//              child: Card(
//                child: widget.memeImage,
//                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                elevation: 3,
//                clipBehavior: Clip.antiAlias,
//              ),
//            ),
              ),
              Text(
                widget.memeDocument.data["caption"],
                style: Constants.TEXT_STYLE_CAPTION_DARK,
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
                child: Text('Go to comments'),
                onPressed: () {
                  openComments(context);
                },
              )
            ],
          ),
        )
    );
  }
}