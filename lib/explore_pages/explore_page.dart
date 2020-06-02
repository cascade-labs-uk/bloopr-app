import 'package:flutter/material.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/explore_pages/search_bar.dart';
import 'package:blooprtest/explore_pages/explore_grid.dart';
import 'package:blooprtest/explore_pages/add_friends_bar.dart';


class ExplorePage extends StatefulWidget {
  ExplorePage({this.toMyProfilePage, this.toSwipePage});

  final VoidCallback toMyProfilePage;
  final VoidCallback toSwipePage;

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  double originalSearchBarHeight = 80.0;
  double expandedSearchBarHeight;
  double searchBarHeight;
  bool searchOpen;

  @override
  void initState() {
    super.initState();

    setState(() {
      searchBarHeight = originalSearchBarHeight;
      searchOpen = false;
    });
  }

  void openSearch() {
    setState(() {
      searchOpen = true;
      searchBarHeight = expandedSearchBarHeight;
    });
  }

  void closeSearch() {
    setState(() {
      searchOpen = false;
      searchBarHeight = originalSearchBarHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    setState(() {
      expandedSearchBarHeight = MediaQuery.of(context).size.height * 0.8;
    });
    if(!searchOpen) {
      body = Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              buildSearch(),
              buildFindFriends(),
              buildExploreGrid(),
              Container(
                color: Constants.OUTLINE_COLOR,
                width: double.infinity,
                height: 0.5,
              ),
              navigationBar()
            ],
          ),
        ),
      );
    } else {
      body = Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              buildSearch(),
            ],
          ),
        ),
      );
    }
    return body;
  }

  Widget buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8,0,8,0),
      child: Container(
        height: searchBarHeight,
        child: ExploreSearchBar(
          openSearch: openSearch,
          closeSearch: closeSearch,
        ),
      ),
    );
  }

  Widget buildFindFriends() {
    return Container(
      height: 100.0,
      width: double.infinity,
      child: AddFriendsBar(key: UniqueKey(),),
    );
  }

  Widget buildExploreGrid() {
    return Expanded(
      child: ExploreGrid(),
    );
  }

  Widget navigationBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      color: Constants.SECONDARY_COLOR,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Constants.EXPLORE_PAGE_ICON, size: 32.0),
            color: Constants.HIGHLIGHT_COLOR,
            onPressed: (){print("home pressed");},
          ),
          IconButton(
            icon: Icon(Constants.SWIPE_PAGE_ICON, size: 32.0),
            color: Constants.INACTIVE_COLOR_DARK,
            onPressed: () {
              print("go to profile page button pressed");
              widget.toSwipePage();
            },
          ),
          IconButton(
            icon: Icon(Constants.PROFILE_PAGE_ICON, size: 32.0),
            color: Constants.INACTIVE_COLOR_DARK,
            onPressed: () {
              print("go to profile page button pressed");
              widget.toMyProfilePage();
            }
          )
        ],
      ),
    );
  }
}
