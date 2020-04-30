import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'profile_card_alignment.dart';
import 'dart:math';
import 'package:blooprtest/backend.dart';
import 'package:blooprtest/config.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:blooprtest/swipe_pages/send_dialog.dart';

List<Alignment> cardsAlign = [
  Alignment(0.0, 0.0),
  Alignment(0.0, 0.0),
  Alignment(0.0, 0.0)
//  Alignment(0.0, 1.0),
//  Alignment(0.0, 0.8),
//  Alignment(0.0, 0.0)
];
List<Size> cardsSize = List(3);

class CardsSectionAlignment extends StatefulWidget {
  CardsSectionAlignment(BuildContext context) {
    cardsSize[0] = Size(MediaQuery.of(context).size.width * 0.90,
        MediaQuery.of(context).size.height * 0.6);
    cardsSize[1] = Size(MediaQuery.of(context).size.width * 0.85,
        MediaQuery.of(context).size.height * 0.55);
    cardsSize[2] = Size(MediaQuery.of(context).size.width * 0.8,
        MediaQuery.of(context).size.height * 0.5);
  }

  @override
  _CardsSectionState createState() => _CardsSectionState();
}

class _CardsSectionState extends State<CardsSectionAlignment>
    with SingleTickerProviderStateMixin { //SingleTicherProviderStateMixin allows us to use vsync, which ensure no unnecessary resources are consumed off-screen

  int cardsCounter = 0;

  List<ProfileCardAlignment> cards = List();
  AnimationController _swipeController;
  AnimationController _flipController;
  BaseBackend backend = new Backend();

  final Alignment defaultFrontCardAlign = Alignment(0.0, 0.0);
  Alignment frontCardAlign;
  double frontCardRot = 0.0;

  @override
  void initState() {
    super.initState();

    BaseBackend backend = new Backend();

    addCards(10); // add initial 10 cards

//    imageURLFuture.then((URL) {
//      // Init cards
//      for (cardsCounter = 0; cardsCounter < 3; cardsCounter++) {
//        cards.add(ProfileCardAlignment(cardsCounter, URL.data['imageURL']));
//      }
//
//      frontCardAlign = cardsAlign[2];
//
//      // Init the animation controller
//      _controller =
//          AnimationController(
//              duration: Duration(milliseconds: 700), vsync: this);
//      _controller.addListener(() => setState(() {}));
//      _controller.addStatusListener((
//          AnimationStatus status) { // calls when the animation is done
//        if (status == AnimationStatus
//            .completed) changeCardsOrder(); // TODO: add the refreshing of new content here
//      });
//    });

//    for (cardsCounter = 0; cardsCounter < 3; cardsCounter++) {
//      cards.add(ProfileCardAlignment(imageURL: 'gs://bloopr-test.appspot.com/user/images/T7ZOeKo9diTXs2ARxBmb1lbLEjI3/more-coronavirus-memes4.jpg', caption:''));
//    }

    frontCardAlign = cardsAlign[2];

    // Init the animation controller
    _swipeController =
        AnimationController(
            duration: Duration(milliseconds: 700), vsync: this);
    _swipeController.addListener(() => setState(() {}));
    _swipeController.addStatusListener((
        AnimationStatus status) { // calls when the animation is done
      if (status == AnimationStatus
          .completed) changeCardsOrder(); // TODO: add the refreshing of new content here
    });

//    _flipController =
//        AnimationController(
//            duration: Duration(milliseconds: 400), vsync: this);
//    _flipController.addListener(() => setState(() {}));
//    _flipController.addStatusListener((
//        AnimationStatus status) { // calls when the animation is done
//      if (status == AnimationStatus
//          .completed) (){}; // TODO: add some call once the flip animation is done
//    });
  }

  void addCards(int numberOfCards) {
    backend.getSentPosts().then((postFutures) {
      for (int counter = 0; counter < postFutures.length; counter++) {
        postFutures[counter].then((postDocument) {
          String memeURL = postDocument.data['imageURL'];
          String memeCaption = postDocument.data['caption'];
          String memePostID = postDocument.documentID;
          if(counter < 3) { // only set state for the first three cards, and let the rest update in the background as they do not affect the widget tree
            setState(() {
              cards.add(ProfileCardAlignment(caption: memeCaption, imageURL: memeURL, postID: memePostID,key: UniqueKey(),));
            });
          } else {
            cards.add(ProfileCardAlignment(caption: memeCaption, imageURL: memeURL, postID: memePostID,key: UniqueKey(),));
          }
        });
      }
    });
    backend.getRecommendedPosts().then((postFutures) {
      for (int counter = 0; counter < postFutures.length; counter++) {
        postFutures[counter].then((postDocument) {
          String memeURL = postDocument.data['imageURL'];
          String memeCaption = postDocument.data['caption'];
          String memePostID = postDocument.documentID;
          if(counter < 3) { // only set state for the first three cards, and let the rest update in the background as they do not affect the widget tree
            setState(() {
              cards.add(ProfileCardAlignment(caption: memeCaption, imageURL: memeURL, postID: memePostID,key: UniqueKey(),));
            });
          } else {
            cards.add(ProfileCardAlignment(caption: memeCaption, imageURL: memeURL, postID: memePostID,key: UniqueKey(),));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(cards.length >= 3) {
      return Expanded(
          child: Stack(
            children: <Widget>[
              backCard(),
              middleCard(),
              frontCard(),
              // Prevent swiping if the cards are animating
              _swipeController.status != AnimationStatus.forward
                  ? SizedBox.expand(
                  child: GestureDetector(
                    //onTap: () {},

                    // While dragging the first card
                    onPanUpdate: (DragUpdateDetails details) {
                      // Add what the user swiped in the last frame to the alignment of the card
                      setState(() {
                        // 20 is the "speed" at which the user moves the card
                        frontCardAlign = Alignment(
                            frontCardAlign.x +
                                25 * // at 20 this moves at the same speed as your finger
                                    details.delta.dx /
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                            frontCardAlign.y +
                                20 *
                                    details.delta.dy /
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height);

                        frontCardRot =
                            frontCardAlign.x * 1.2; // * rotation speed;
                      });
                    },
                    // When releasing the first card
                    onPanEnd: (_) {
                      // If the front card was swiped far enough to count as swiped
                      if (frontCardAlign.x > 3.0 || frontCardAlign.x < -3.0 ||
                          frontCardAlign.y > 3.0 || frontCardAlign.y < -3.0) {
                        addInteraction(context);
                        animateCards();
                      } else {
                        // Return to the initial rotation and alignment
                        setState(() {
                          frontCardAlign = defaultFrontCardAlign;
                          frontCardRot = 0.0;
                        });
                      }
                    },
                  ))
                  : Container(),
            ],
          ));
    } else {
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(backgroundColor: Constants.HIGHLIGHT_COLOR,),
        ),
      );
    }
  }

  void addInteraction(context) {
    Alignment beginAlign = frontCardAlign;
    String currentPostID = cards[0].postID;
    if (beginAlign.y > 0 && beginAlign.x < 3.0 && beginAlign.x > -3.0) {
      backend.addSaveAndLike(currentPostID);
    } else if (beginAlign.y < 0 && beginAlign.x < 3.0 && beginAlign.x > -3.0) {
      print("share file");
      showDialog(
        context: context,
        child: SendDialog(
          context: context,
          currentPostID: currentPostID,
        )
      );
      //shareImage();
    } else if (beginAlign.x > 0) {
      backend.addLike(currentPostID);
    } else if (beginAlign.x < 0) {
      backend.addDislike(currentPostID);
    }
  }

  Future<void> shareImage() async {
    await Share.file('image', 'image.png', cards[0].imageBytes, "image/png", text: "my image");
  }

  Widget backCard() {
    return Align(
      alignment: _swipeController.status == AnimationStatus.forward // if animation is active
          ? CardsAnimation.backCardAlignmentAnim(_swipeController).value // animate the alignment of the backCard into the middleCard
          : cardsAlign[0], // otherwise reset its alignment
      child: SizedBox.fromSize(
          size: _swipeController.status == AnimationStatus.forward // if animation is active
              ? CardsAnimation.backCardSizeAnim(_swipeController).value // animate the resizing of the backCard into the middleCard
              : cardsSize[2], // otherwise reset its size
          child: cards[2]),
    );
  }

  Widget middleCard() {
    return Align(
      alignment: _swipeController.status == AnimationStatus.forward
          ? CardsAnimation.middleCardAlignmentAnim(_swipeController).value
          : cardsAlign[1],
      child: SizedBox.fromSize(
          size: _swipeController.status == AnimationStatus.forward
              ? CardsAnimation.middleCardSizeAnim(_swipeController).value
              : cardsSize[1],
          child: cards[1]),
    );
  }

  Widget frontCard() {
    return Align(
        alignment: _swipeController.status == AnimationStatus.forward
            ? CardsAnimation.frontCardDisappearAlignmentAnim(
            _swipeController, frontCardAlign)
            .value
            : frontCardAlign,
        child: Transform.rotate(
          angle: (pi / 180.0) * frontCardRot,
//          child: DecoratedBox(
//            decoration: BoxDecoration(
//              borderRadius: BorderRadius.circular(15)
//            ),
//            child: SizedBox.fromSize(
//              size: cardsSize[0],
//              child: cards[0],
//            ),
//          ),
//          child: ClipRRect(
//            borderRadius: BorderRadius.circular(30),
//            child: SizedBox.fromSize(
//              size: cardsSize[0],
//              child: cards[0],
//            ),
//          ),
          child: SizedBox.fromSize(
            size: cardsSize[0],
            child: cards[0],
          ),
        )
    );
  }

  void changeCardsOrder() {
    setState(() {
      // Swap cards (back card becomes the middle card; middle card becomes the front card, front card becomes a  bottom card)
      print(cards[0].imageURL);
      print(cards[1].imageURL);
      print(cards[2].imageURL);

      //remove 1 card and replace it with a new card in the background
      cards.removeAt(0);
      addCards(1);

      frontCardAlign = defaultFrontCardAlign;
      frontCardRot = 0.0;
    });
  }

  void animateCards() {
    _swipeController.stop();
    _swipeController.value = 0.0;
    _swipeController.forward();
  }
}

class CardsAnimation {
  static Animation<Alignment> backCardAlignmentAnim(
      AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[0], end: cardsAlign[1]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Size> backCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[2], end: cardsSize[1]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Alignment> middleCardAlignmentAnim(
      AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[1], end: cardsAlign[2]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Size> middleCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[1], end: cardsSize[0]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Alignment> frontCardDisappearAlignmentAnim(
      AnimationController parent, Alignment beginAlign) {
    return AlignmentTween(
        begin: beginAlign,
        end: Alignment( //
            getFinalXAlignment(beginAlign),
            getFinalYAlignment(beginAlign)) // Has swiped to the left or right?
    )
        .animate(CurvedAnimation(
        parent: parent, curve: Interval(0.0, 0.5, curve: Curves.easeIn)));
  }

  static double getFinalXAlignment(Alignment beginAlign) {
    if (beginAlign.x < 3.0 && beginAlign.x > -3.0) {
      return 0;
    } else if (beginAlign.x > 0) {
      return beginAlign.x + 30.0;
    } else {
      return beginAlign.x - 30.0;
    }
  }

  static double getFinalYAlignment(Alignment beginAlign) {
    if (beginAlign.y > 0 && beginAlign.x < 3.0 && beginAlign.x > -3.0) {
      return beginAlign.y + 30.0;
    } else if (beginAlign.y < 0 && beginAlign.x < 3.0 && beginAlign.x > -3.0) {
      return beginAlign.y - 30.0;
    } else {
      return 0;
    }
  }
}
