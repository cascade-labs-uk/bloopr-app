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
  List<String> currentPostIDs = [];

  @override
  void initState() {
    super.initState();

    int startingPostNumber = 15;

    addExplorePosts(startingPostNumber, currentPostIDs);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if(currentPostIDs.length == postFutures.length && postFutures.length >= 15) {
          addExplorePosts(9, currentPostIDs);
        }
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

  void addExplorePosts(int number, List<String> exclude) {
    widget.backend.getExplorePostFutures(number,exclude: exclude).then((futuresList) {
      print("futuresList: " + futuresList.toString());
      setState(() {
        postFutures.addAll(futuresList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: postFutures.length,
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3
      ),
      itemBuilder: (BuildContext context, int index) {
        print("item build - index: ${index.toString()}");
        return gridTile(postFutures[index], index);
      },
    );
  }

  Widget gridTile(Future<DocumentSnapshot> postFuture, int index) {
    return FutureBuilder(
      future: postFuture,
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        Widget child;
        if(snapshot.hasData) {
          currentPostIDs.add(snapshot.data.documentID);
          child = GestureDetector(
            onTap: () {
              openViewMemePage(
                  context,
                  Image.network(snapshot.data.data['imageURL']),
                  snapshot.data,
                  snapshot.data.documentID + index.toString()
              );
            },
            child: Padding(
              padding: index % 3 == 1
                  ? EdgeInsets.fromLTRB(1.5, 0.75, 1.5, 0.75)
                  : EdgeInsets.fromLTRB(0, 0.75, 0, 0.75),
              child: Container(
                color: Constants.SECONDARY_COLOR,
                child: Hero(
                    tag: snapshot.data.documentID + index.toString(),
                    child: Image.network(
                      snapshot.data.data['imageURL'],
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
        } else {
          child = Padding(
            padding: index % 3 == 1
                ? EdgeInsets.fromLTRB(1.5, 0.75, 1.5, 0.75)
                : EdgeInsets.fromLTRB(0, 0.75, 0, 0.75),
            child: Container(
              color: Constants.SECONDARY_COLOR,
              width: 100,
              height: 100,
            ),
          );
        }
        return child;
      },
    );
  }
}
