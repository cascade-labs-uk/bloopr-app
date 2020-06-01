//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/backend.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/view_post_page.dart';

class ExploreGrid extends StatefulWidget {

  final BaseBackend backend = new Backend();

  @override
  _ExploreGridState createState() => _ExploreGridState();
}

class _ExploreGridState extends State<ExploreGrid> {

  ScrollController _scrollController = new ScrollController();
  List<Future> postFutures = [];
  List<DocumentSnapshot> postDocuments = [];

  @override
  void initState() {
    super.initState();

    int startingPostNumber = 15;

    addExplorePosts(startingPostNumber);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        addExplorePosts(9);
      }
    });
  }

  Future openViewMemePage(BuildContext context, Image memeImage,
      DocumentSnapshot memeDocument, String heroTag) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        ViewPostPage(
          memeDocument: memeDocument,
          memeImage: memeImage,
          pageTitle: "Explore",
          tag: heroTag,)));
  }

  void addExplorePosts(int number) {
    widget.backend.getExplorePosts(number).then((postsQuerySnapshot) {
      for (int counter = 0; counter <
          postsQuerySnapshot.documents.length; counter++) {
        print(
            'adding post ${postsQuerySnapshot.documents[counter].documentID}');
        setState(() {
          postDocuments.add(postsQuerySnapshot.documents[counter]);
          postFutures.add(widget.backend.getImageFromLocation(
              postsQuerySnapshot.documents[counter].data['imageURL']));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: postDocuments.length,
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3
      ),
      itemBuilder: (BuildContext context, int index) {
        return gridTile(postDocuments[index], index);
      },
    );
  }

  Widget gridTile(DocumentSnapshot postDocument, int index) {
    String heroTag = postDocument.documentID + index.toString();

    return GestureDetector(
      onTap: () {
        openViewMemePage(
            context,
            Image.network(postDocument.data['imageURL']),
            postDocument,
            heroTag
        );
      },
      child: Padding(
        padding: index % 3 == 1
            ? EdgeInsets.fromLTRB(1.5, 0.75, 1.5, 0.75)
            : EdgeInsets.fromLTRB(0, 0.75, 0, 0.75),
        child: Container(
          color: Constants.SECONDARY_COLOR,
          child: Hero(
              tag: heroTag,
              child: Image.network(
                postDocument.data['imageURL'],
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                cacheWidth: 200,
                cacheHeight: 200,
              )
          ),
        ),
      ),
    );
  }
}
