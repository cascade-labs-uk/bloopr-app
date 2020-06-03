import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blooprtest/backend.dart';
import 'comment_card.dart';
import 'package:blooprtest/config.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewPostPage extends StatefulWidget {
  ViewPostPage({this.memeImage, this.memeDocument, this.isSavedPost = false, this.pageTitle, this.memeIndex, this.tag});

  final Image memeImage;
  final DocumentSnapshot memeDocument;
  final bool isSavedPost;
  final String pageTitle;
  final int memeIndex;
  final String tag;
  final BaseBackend backend = new Backend();

  @override
  _ViewPostPageState createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  final formKey = new GlobalKey<FormState>();
  bool unsaved = false;
  bool reported = false;
  String heroTag;

  List<DocumentSnapshot> postComments = [];
  String userCommentText;

  bool validateAndSave() {
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if(validateAndSave()) {
      try {
        widget.backend.postUserComment(widget.memeDocument.documentID, userCommentText);
        formKey.currentState.reset();
        Future.delayed(Duration(milliseconds: 800), (){
          postComments = [];
          addCommentCards();
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void addCommentCards() {
    widget.backend.getImageComments(widget.memeDocument.documentID).then((commentsSnapshot) {
      setState(() {
        for(int counter = 0; counter < commentsSnapshot.documents.length; counter++) {
          if(commentsSnapshot.documents[counter].exists) {
            postComments.add(commentsSnapshot.documents[counter]);
          }
        }
      });
    });
  }

  void unsavePost() {
    if(unsaved==false){
      widget.backend.unsavePost(widget.memeDocument.documentID);
    }
  }

  @override
  void initState() {
    super.initState();
    if(widget.tag != null) {
      heroTag = widget.tag;
    } else if (widget.memeIndex != null) {
      heroTag = widget.memeDocument.documentID + widget.memeIndex.toString();
    } else {
      heroTag = widget.memeDocument.documentID;
    }

    addCommentCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.75,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Constants.INACTIVE_COLOR_DARK, size: 22.5,),
          onPressed: () {
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
              padding: const EdgeInsets.fromLTRB(14,2.5,14,2.5),
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
                          height: 30,
                          width: 30,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 0.0),
                    child: Visibility(
                      visible: widget.isSavedPost,
                      child: IconButton(
                        icon: Icon(unsaved?Icons.bookmark_border:Icons.bookmark),
                        color: Constants.HIGHLIGHT_COLOR,
                        onPressed: () {
                          unsavePost();
                          setState(() {
                            unsaved = true;
                          });
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.isSavedPost == false,
                    child: IconButton(
                      icon: Icon(Icons.more_horiz, color: Constants.DARK_TEXT, size: 22.5,),
                      onPressed: () {

                      },
                    ),




//                    child: RaisedButton(
//                      shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.circular(5.0),
//                          side: BorderSide(
//                            color: Constants.DARK_TEXT,
//                            width: 0.5,
//                          )
//                      ),
//                      elevation: 0,
//                      color: Constants.BACKGROUND_COLOR,
//                      child: reported?Text('Reported'):Text('Report'),
//                      onPressed: () {
//                        if(reported == false) {
//                          setState(() {
//                            reported = true;
//                          });
//                          widget.backend.reportMeme(widget.memeDocument.documentID);
//                        }
//                      },
//                    )
                  )
                ],
              ),
            ),
            Hero(
              tag: widget.memeDocument.documentID,
              child: widget.memeImage,
//            child: Padding(
////              padding: const EdgeInsets.all(6.0),
////              child: Card(
////                child: widget.memeImage,
////                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
////                elevation: 3,
////                clipBehavior: Clip.antiAlias,
////              ),
////            ),
            ),
            Text(
              widget.memeDocument.data["caption"],
              style: Constants.TEXT_STYLE_CAPTION_DARK,
            ),
            buildComments()
          ],
        ),
      )
    );
  }

  Widget buildComments() {
    return Expanded(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: postComments.length,
              itemBuilder: (context, index) {
                return CommentCard(
                  commentDocument: postComments[index],
                  parentPostID: widget.memeDocument.documentID,
                );
              },
            ),
          ),
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0,8.0,4.0,8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Type something...',
                          hintStyle: Constants.TEXT_STYLE_HINT_DARK,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(80),
                              borderSide: BorderSide(
                                color: Constants.SECONDARY_COLOR,
                              )
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(80),
                              borderSide: BorderSide(
                                color: Constants.HIGHLIGHT_COLOR,

                              )
                          )
                      ),
                      validator: (value) => value.isEmpty ? 'Type Something...' : null,
                      obscureText: false,
                      onSaved: (value) => userCommentText = value,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Constants.HIGHLIGHT_COLOR),
                    onPressed: validateAndSubmit,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

