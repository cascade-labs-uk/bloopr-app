import 'package:blooprtest/asset_management/custom_icons_icons.dart';
import 'package:blooprtest/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/profile_pages/profile_page_header.dart';
import 'package:blooprtest/upload_pages/upload_meme.dart';
import 'package:blooprtest/upload_pages/upload_profile_picture.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:blooprtest/view_post_page.dart';
import 'package:blooprtest/auth.dart';


class BaseProfilePage extends StatefulWidget {
  BaseProfilePage({this.displayedUserFirestoreID, this.displayedUserID, this.userDocument, this.isOwnProfile, this.auth, this.onSignedOut});

  final String displayedUserFirestoreID;
  final String displayedUserID;
  final DocumentSnapshot userDocument;
  final bool isOwnProfile;
  final Auth auth;
  final VoidCallback onSignedOut;

  BaseBackend backend = new Backend();

  @override
  _BaseProfilePageState createState() => _BaseProfilePageState();
}

enum GridType {
  savedMemes,
  posts
}

class _gridSelectSliverDelegate extends SliverPersistentHeaderDelegate {
  _gridSelectSliverDelegate({this.maxExtent, this.minExtent, this.viewPosts, this.viewSaved, this.gridType, this.isOwnProfile});

  final double minExtent;
  final double maxExtent;
  final VoidCallback viewSaved;
  final VoidCallback viewPosts;
  GridType gridType;
  bool isOwnProfile;

  Future openUploadMeme(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => UploadMeme()));
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Constants.SECONDARY_COLOR,
      child: Column(
        children: <Widget>[
          Container(
            color: Constants.OUTLINE_COLOR,
            width: double.infinity,
            height: 0.5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: isOwnProfile,
                child: IconButton(
                  icon: Icon(Icons.bookmark),
                  onPressed: () {
                    gridType = GridType.savedMemes;
                    viewSaved();
                  },
                  color: gridType==GridType.savedMemes?Constants.DARK_TEXT:Constants.INACTIVE_COLOR_DARK,
                ),
              ),
              IconButton(
                icon: Icon(Constants.GRID, size: 25.0,),
                onPressed: (){
                  gridType = GridType.posts;
                  viewPosts();
                },
                color: gridType==GridType.posts?Constants.DARK_TEXT:Constants.INACTIVE_COLOR_DARK,
              ),
              Visibility(
                visible: isOwnProfile,
                child: IconButton(
                  icon: Icon(Icons.brush),
                  color: Constants.INACTIVE_COLOR_DARK,
                  onPressed: () {
                    openUploadMeme(context);
                  },
                ),
              ),
            ],
          ),
          Container(
            color: Constants.OUTLINE_COLOR,
            width: double.infinity,
            height: 0.5,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_gridSelectSliverDelegate oldDelegate) { //change this so it rebuilds when a different icon is clicked
    return maxExtent != oldDelegate.maxExtent ||
        minExtent != oldDelegate.minExtent ||
        gridType == oldDelegate.gridType;
  }
}

class _BaseProfilePageState extends State<BaseProfilePage> {
  GridType _currentGrid = GridType.posts;
  List<Future> postImageFutures = [];
  List<Future> savedPostImageFutures = [];
  List<DocumentSnapshot> postDocuments = [];
  List<DocumentSnapshot> savedPostDocuments = [];
  int maxImageSize = 7 * 1024 * 1024;

  Future openViewMemePage(context, Image memeImage, DocumentSnapshot memeDocument, String heroTag,{isSavedPost = false, isOwnPost = false}) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPostPage(
      memeDocument: memeDocument,
      memeImage: memeImage,
      isSavedPost: isSavedPost,
      pageTitle: isSavedPost?"Saved":"Post",
      tag: heroTag,
      isOwnPost: isOwnPost,
    )));
  }

  @override
  void initState() {
    super.initState();

    widget.backend.getUserPosts(widget.displayedUserID).then((querySnapshot) {
      print("number of posted posts: ${querySnapshot.documents.length}");
      for (int counter = 0; counter < querySnapshot.documents.length; counter++) {
        FirebaseStorage.instance.getReferenceFromUrl(querySnapshot.documents[counter].data['imageURL'])
          .then((imageReference) {
            setState(() {
              postImageFutures.add(imageReference.getData(maxImageSize));
              postDocuments.add(querySnapshot.documents[counter]);
            });
        });
      }
    });

    widget.backend.getUserSaveInteractions(widget.displayedUserFirestoreID).then((querySnapshot) {
      for (int counter = 0; counter < querySnapshot.documents.length; counter++) {
        widget.backend.getPost(querySnapshot.documents[counter].data['postID']).then((postDocument) {
          setState(() {
            savedPostImageFutures.add(
                widget.backend.getImageFromPostID(postDocument.documentID)
            );
            savedPostDocuments.add(postDocument);
          });
        });
      }
    });
  }

  void _viewSaved() {
    setState(() {
      _currentGrid = GridType.savedMemes;
    });
  }

  void  _viewPosts() {
    setState(() {
      _currentGrid = GridType.posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 448.0,
            flexibleSpace: FlexibleSpaceBar(
              background: ProfilePageHeader(
                userID: widget.displayedUserID,
                userDocument: widget.userDocument,
                isOwnProfile: widget.isOwnProfile,
                auth: widget.auth,
                onSignedOut: widget.onSignedOut
              ),
            ),
          ),
          buildGridSelect(),
          buildImageGrid()
        ],
      ),
    );
  }



  SliverGrid buildImageGrid() {
    if(_currentGrid == GridType.posts) {
      if(postImageFutures.length == 0) {
        return SliverGrid.count(
          crossAxisCount: 1,
          children: [Container(
            color: Constants.BACKGROUND_COLOR,
            height: 120.0,
            child: Center(
              heightFactor: 120,
              child: Text(
                "You haven't posted anything!",
                style: Constants.TEXT_STYLE_CAPTION_GREY,
              ),
            ),
          )],
        );
      } else {
        return SliverGrid.count(
          crossAxisCount: 3,
          children: postedPostGridChildren(postImageFutures),
        );
      }
    } else if(_currentGrid == GridType.savedMemes) {
      if(savedPostImageFutures.length == 0) {
        return SliverGrid.count(
          crossAxisCount: 1,
          children: [Container(
            color: Constants.BACKGROUND_COLOR,
            height: 120.0,
            child: Center(
              child: Text(
                'Swipe down to save some memes!',
                style: Constants.TEXT_STYLE_CAPTION_GREY,
              ),
            ),
          )],
        );
      } else {
        return SliverGrid.count(
          crossAxisCount: 3,
          children: savedPostGridChildren(savedPostImageFutures),
        );
      }
    }
  }

  List<Widget> savedPostGridChildren(List<Future> postFutures) {
    List<Widget> children = [];

    for (int counter = 0; counter < postFutures.length; counter++) {
      String heroTag = savedPostDocuments[counter].documentID + counter.toString();
      children.add(
        GestureDetector(
          onTap: () {
            openViewMemePage(
              context,
              Image.network(savedPostDocuments[counter].data['imageURL']),
              savedPostDocuments[counter],
              heroTag,
              isSavedPost: true
            );
          },
          child: Padding(
            padding: counter%3==1?EdgeInsets.fromLTRB(1.5,0.75,1.5,0.75):EdgeInsets.fromLTRB(0,0.75,0,0.75),
            child: Container(
              color: Constants.SECONDARY_COLOR,
              child: Hero(
                  tag: heroTag,
                  child: Image.network(
                    savedPostDocuments[counter].data['imageURL'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    cacheWidth: 200,
                    cacheHeight: 200,
                  )
              ),
            ),
          ),
        )
      );
    }

    return children;
  }

  List<Widget> postedPostGridChildren(List<Future> postFutures) {
    List<Widget> children = [];

    for (int counter = 0; counter < postFutures.length; counter++) {
      String heroTag = postDocuments[counter].documentID + counter.toString();
      children.add(
          GestureDetector(
            onTap: () {
              openViewMemePage(
                context,
                Image.network(postDocuments[counter].data['imageURL']),
                postDocuments[counter],
                heroTag,
                isSavedPost: false,
                isOwnPost: widget.isOwnProfile
              );
            },
            child: Padding(
              padding: counter%3==1?EdgeInsets.fromLTRB(1.5,0.75,1.5,0.75):EdgeInsets.fromLTRB(0,0.75,0,0.75),
              child: Container(
                color: Constants.SECONDARY_COLOR,
                child: Hero(
                    tag: heroTag,
                    child: Image.network(
                      postDocuments[counter].data['imageURL'],
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      cacheWidth: 200,
                      cacheHeight: 200,
                    )
                ),
              ),
            ),
          )
      );
    }

    return children;
  }

  SliverPersistentHeader buildGridSelect() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _gridSelectSliverDelegate(
        minExtent: 49.0,
        maxExtent: 49.0,
        viewPosts: _viewPosts,
        viewSaved: _viewSaved,
        gridType: _currentGrid,
        isOwnProfile: widget.isOwnProfile
      ),
    );
  }
}
