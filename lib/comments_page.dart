import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/comment_card.dart';
import 'package:blooprtest/backend.dart';

class CommentsPage extends StatefulWidget {
  CommentsPage({this.memeDocument});

  final DocumentSnapshot memeDocument;
  final BaseBackend backend = new Backend();

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
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
        postComments = [];
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
    addCommentCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Constants.INACTIVE_COLOR_DARK, size: 22.5,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Comments', style: Constants.TEXT_STYLE_HEADER_DARK,),
          backgroundColor: Constants.SECONDARY_COLOR,
        ),
        body: Container(
          color: Constants.BACKGROUND_COLOR,
          child: Column(
            children: <Widget>[
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
                  key: UniqueKey(),
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
      ),
    );
  }
}
