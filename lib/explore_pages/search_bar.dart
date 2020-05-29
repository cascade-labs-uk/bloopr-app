import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/backend.dart';
import 'package:blooprtest/profile_pages/user_profile_page.dart';

class ExploreSearchBar extends StatefulWidget {
  ExploreSearchBar({this.openSearch, this.closeSearch});

  final VoidCallback openSearch;
  final VoidCallback closeSearch;

  BaseBackend backend = new Backend();

  @override
  _ExploreSearchBarState createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends State<ExploreSearchBar> {
  List<String> userList = [];

  Future openUserProfile(context, String userFirestoreID) async {
    widget.backend.getUser(userFirestoreID).then((userDocument) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(
        displayedUserFirestoreID: userFirestoreID,
        displayedUserID: userDocument.data["userID"],
        userDocument: userDocument,
      )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar<SearchResult>(
      debounceDuration: Duration(milliseconds: 150),
      icon: Icon(Icons.search, size: 22.5,),
      cancellationWidget: Text(
          "Cancel",
          style: Constants.TEXT_STYLE_CAPTION_GREY
      ),
      hintText: "Search",
      minimumChars: 0,
      searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
      emptyWidget: Text(
        "No Result Found",
        style: Constants.TEXT_STYLE_HEADER_DARK,
      ),
      onSearch: search,
      onCancelled: widget.closeSearch,
      onItemFound: (SearchResult searchResult, int index) {
        return ListTile(
          onTap: () {
            openUserProfile(context, searchResult.userID);
          },
          leading: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: Constants.OUTLINE_COLOR,
                    width: 0.5
                ),
                borderRadius: BorderRadius.circular(70)
            ),
            child: ClipRRect(
                child: FutureBuilder(
                  future: widget.backend.getProfilePictureFromFirestoreID(searchResult.userID),
                  builder: (context, snapshot) {
                    Widget displayed;
                    if(snapshot.hasData) {
                      displayed = Image.memory(
                        snapshot.data,
                        height: 50,
                        width: 50,
                      );
                    } else {
                      displayed = Image.asset(
                        'assets/profile_image_placeholder.png',
                        height: 50,
                        width: 50,
                      );
                    }

                    return displayed;
                  },
                ),
                borderRadius: BorderRadius.circular(25.0),
          ),
        ),
          title: Text(searchResult.userName),
        );
      },
    );
  }

  Future<List<SearchResult>> search(String searchFor) async {
    widget.openSearch();
    return widget.backend.getSearchResults(searchFor).then((resultsResponse) {
      List<SearchResult> searchResults = [];
      for (int counter = 0; counter < resultsResponse.length; counter++) {
        searchResults.add(
          SearchResult(
            userID: resultsResponse[counter]['firestoreID'],
            userName: resultsResponse[counter]['nickname']
          )
        );
      }
      return searchResults;
    });
  }
}

class SearchResult {
  SearchResult({this.userID, this.userName});
  final String userName;
  final String userID;
}


