import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/backend.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:blooprtest/comment_card.dart';
import 'package:blooprtest/config.dart';
import 'package:flip_card/flip_card.dart';

class ProfileCardAlignment extends StatefulWidget {
  ProfileCardAlignment({this.imageURL,this.caption,this.postID,Key key}) : super(key: key);

  final String imageURL;
  final String caption;
  final String postID;
  Uint8List imageBytes;
  Widget displayImage;
  BaseBackend backend = new Backend();

  @override
  _ProfileCardAlignmentState createState() => _ProfileCardAlignmentState();
}

enum CardSide {
  meme,
  comments
}

class _ProfileCardAlignmentState extends State<ProfileCardAlignment> {

  final formKey = new GlobalKey<FormState>();
  CardSide _cardSide = CardSide.meme;
  int maxImageSize = 8*1024*1024;
  //Widget displayImage;
  List<CommentCard> commentCards = [];
  BaseBackend backend = new Backend();
  String userCommentText;
  bool reported = false;


  @override
  void initState() {
    super.initState();
    if(widget.displayImage == null) {
      widget.displayImage = Center(child: CircularProgressIndicator(backgroundColor: Constants.HIGHLIGHT_COLOR,));

      print("init state for profile card run");

      FirebaseStorage.instance.getReferenceFromUrl(widget.imageURL).then((imageReference) {
        imageReference.getData(maxImageSize).then((data) {
          setState(() {
            widget.imageBytes = data;
            widget.displayImage = Image.memory(data);
          });
        });
      });
    }

    addCommentCards();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: changeCardSide,
        child: BuildCard())
    );
  }

  void addCommentCards() {
    Future<QuerySnapshot> futureComments = backend.getImageComments(widget.postID);
    futureComments.then((querySnapshot) {
      for (int counter = 0; counter < querySnapshot.documents.length; counter++) {
        String commentID = querySnapshot.documents[counter].documentID;
        String commenterNickname = querySnapshot.documents[counter].data['commenter name'];
        String commentText = querySnapshot.documents[counter].data['text'];
        setState(() {
          commentCards.add(CommentCard(
            commentDocument: querySnapshot.documents[counter],
            parentPostID: widget.postID,
          ));
        });
      }
    });
  }

  void changeCardSide() {
    setState(() {
      if(_cardSide == CardSide.meme) {
        _cardSide = CardSide.comments;
      } else {
        _cardSide = CardSide.meme;
      }
    });
  }

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
        backend.postUserComment(widget.postID, userCommentText);
        formKey.currentState.reset();
        Future.delayed(Duration(milliseconds: 800), (){
          commentCards = [];
          addCommentCards();
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Widget BuildCard() {
//    return FlipCard(
//      direction: FlipDirection.HORIZONTAL,
//      onFlip: changeCardSide,
//      front: Stack(
//        children: <Widget>[
//          SizedBox.expand(
//            child: Material(
//              borderRadius: BorderRadius.circular(12.0),
//              child: widget.displayImage,
//            ),
//          ),
//          SizedBox.expand(
//            child: Container(
//              decoration: BoxDecoration(
//                  gradient: LinearGradient(
//                      colors: [Colors.transparent, Colors.black54],
//                      begin: Alignment.center,
//                      end: Alignment.bottomCenter)),
//            ),
//          ),
//          Align(
//            alignment: Alignment.bottomLeft,
//            child: Container(
//                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.end,
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Text('${widget.caption}',
//                        style: TextStyle(
//                            color: Colors.white,
//                            fontSize: 20.0,
//                            fontWeight: FontWeight.w700)),
//                    Padding(padding: EdgeInsets.only(bottom: 8.0)),
//                    Text('A short description.',
//                        textAlign: TextAlign.start,
//                        style: TextStyle(color: Colors.white)),
//                  ],
//                )),
//          )
//        ],
//      ),
//      back: Column(
//        children: <Widget>[
//          Container(
//              child: Padding(
//                padding: const EdgeInsets.all(8.0),
//                child: Text(
//                  'comments',
//                  style: TextStyle(
//                      fontSize: 16.0,
//                      fontWeight: FontWeight.bold
//                  ),
//                ),
//              )
//          ),
//          Expanded(
//            child: ListView(
//              scrollDirection: Axis.vertical,
//              children: commentCards,
//            ),
//          ),
//          Form(
//            key: formKey,
//            child: Row(
//              children: <Widget>[
//                Expanded(
//                  child: TextFormField(
//                    decoration: InputDecoration(
//                      labelText: 'type something...',
//                      labelStyle: TextStyle(
//                        color: Colors.black,
//                      ),
//                    ),
//                    validator: (value) => value.isEmpty ? 'write your comment fool' : null,
//                    obscureText: false,
//                    onSaved: (value) => userCommentText = value,
//                  ),
//                ),
//                IconButton(
//                  icon: Icon(Icons.send, color: constants.HIGHLIGHT_COLOR),
//                  onPressed: validateAndSubmit,
//                )
//              ],
//            ),
//          )
//        ],
//      ),
//    );
    if(_cardSide == CardSide.meme){ // return the meme side of the card
      return Stack(
        overflow: Overflow.clip,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: AspectRatio(
              aspectRatio: 0.9,
              child: Material(
                borderRadius: BorderRadius.circular(12.0),
                child: widget.displayImage,
              ),
            ),
          ),
//          SizedBox.expand(
//            child: Container(
//              decoration: BoxDecoration(
//                  gradient: LinearGradient(
//                      colors: [Colors.transparent, Colors.black54],
//                      begin: Alignment.center,
//                      end: Alignment.bottomCenter)),
//            ),
//          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                height: 80,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Text('${widget.caption}',
                        style: Constants.TEXT_STYLE_CAPTION_DARK
                ),
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.end,
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Text('${widget.caption}',
//                        style: TextStyle(
//                            color: Colors.white,
//                            fontSize: 20.0,
//                            fontWeight: FontWeight.w700)),
//                    Padding(padding: EdgeInsets.only(bottom: 8.0)),
//                    Text('A short description.',
//                        textAlign: TextAlign.start,
//                        style: TextStyle(color: Colors.white)),
//                  ],
//                ),
                color: Constants.BACKGROUND_COLOR,
            ),
          )
        ],
      );
    } else { // return the comment side of the card
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                color: Constants.BACKGROUND_COLOR,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Comments (${commentCards.length})',
                    style: Constants.TEXT_STYLE_HEADER_DARK
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(
                        color: Constants.DARK_TEXT,
                        width: 0.5,
                      )
                  ),
                  elevation: 0,
                  color: Constants.BACKGROUND_COLOR,
                  child: reported?Text('Reported'):Text('Report'),
                  onPressed: () {
                    if(reported == false) {
                      setState(() {
                        reported = true;
                      });
                      widget.backend.reportMeme(widget.postID);
                    }
                  },
                ),
              )
            ],
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: commentCards,
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
                      validator: (value) => value.isEmpty ? 'Write your comment fool' : null,
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
      );
    }
  }
}

