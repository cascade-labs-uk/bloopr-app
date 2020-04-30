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

  List<Widget> items;
  ScrollController _scrollController = new ScrollController();
  List<Future> postFutures = [];
  List<DocumentSnapshot> postDocuments = [];

  @override
  void initState() {
    super.initState();

    items = placeholderGrid();

    int startingPostNumber = 15;

    addExplorePosts(startingPostNumber);
    
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        addExplorePosts(9);
      }
    });
  }

  Future openViewMemePage(context, memeImage, memeDocument) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPostPage(memeDocument: memeDocument, memeImage: memeImage, pageTitle: "Explore",)));
  }

  void addExplorePosts(int number) {
    widget.backend.getExplorePosts(number).then((postsQuerySnapshot) {
      setState(() {
        postDocuments.addAll(postsQuerySnapshot.documents);
      });
      for (int counter = 0; counter < postsQuerySnapshot.documents.length; counter++) {
        setState(() {
          postFutures.add(widget.backend.getImageFromLocation(postsQuerySnapshot.documents[counter].data['imageURL']));
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
        return gridTile(postDocuments[index], index) ;
      },
    );
  }

  Widget gridTile(DocumentSnapshot postDocument, int index) {
    return FutureBuilder(
      future: widget.backend.getImageFromLocation(postDocument.data['imageURL']),
      builder: (context, snapshot) {
        Widget child;
        if(snapshot.hasData) {
          child = GestureDetector(
            onTap: () {
              openViewMemePage(
                context,
                Image.memory(snapshot.data),
                postDocument
              );
            },
            child: Hero(
              tag: postDocument.documentID,
              child: Image.memory(
                snapshot.data,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          child = Container(
            color: Constants.SECONDARY_COLOR,
            height: 100,
            width: 100,
          );
        }
        if(index%3 == 1) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(1.5,0.75,1.5,0.75),
            child: child,
          );
        } else {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0,0.75,0,0.75),
            child: child,
          );
        }
      },
    );
  }

  List<Widget> placeholderGrid() {
    return [
      Container(color: Colors.red, height: 150.0),
      Container(color: Colors.purple, height: 150.0),
      Container(color: Colors.green, height: 150.0),
      Container(color: Colors.orange, height: 150.0),
      Container(color: Colors.yellow, height: 150.0),
      Container(color: Colors.pink, height: 150.0),
      Container(color: Colors.cyan, height: 150.0),
      Container(color: Colors.indigo, height: 150.0),
      Container(color: Colors.blue, height: 150.0),
      Container(color: Colors.red, height: 150.0),
      Container(color: Colors.purple, height: 150.0),
      Container(color: Colors.green, height: 150.0),
    ];
  }
}
