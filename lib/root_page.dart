import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/swipe_pages/swipe_page.dart';
import 'package:blooprtest/profile_pages/my_profile_page.dart';
import 'package:blooprtest/explore_pages/explore_page.dart';
import 'package:blooprtest/load_speed_test.dart';
import 'package:blooprtest/error_page.dart';
import 'package:blooprtest/login_pages/root_login_page.dart';
import 'auth.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn
}

enum Pages {
  swipe,
  profile,
  discover,
  test
}

class _RootPageState extends State<RootPage> {

  AuthStatus _authStatus = AuthStatus.notSignedIn;
  Pages _currentPage;

  void initState() {
    super.initState();
    setState(() {
      _currentPage = Pages.swipe;
    });
    widget.auth.currentUser().then((userId) {
      setState(() {
        _authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      _authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      _authStatus = AuthStatus.notSignedIn;
    });
  }

  void _toSwipePage() {
    setState(() {
      _currentPage = Pages.swipe;
    });
  }

  void _toMyProfilePage() {
    setState(() {
      _currentPage = Pages.profile;
    });
  }

  void _toDiscoverPage() {
    setState(() {
      _currentPage = Pages.discover;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authStatus == AuthStatus.notSignedIn) {
      return LoginPage(
        auth: widget.auth,
        onSignedIn: _signedIn,
      );
    } else {
      if(_currentPage == Pages.swipe) {
        return SwipePage(
          auth: widget.auth,
          onSignedOut: _signedOut,
          toDiscoverPage: _toDiscoverPage,
          toMyProfilePage: _toMyProfilePage,
        );
      } else if(_currentPage == Pages.profile) {
        return MyProfilePage(
          auth: widget.auth,
          onSignedOut: _signedOut,
          toDiscoverPage: _toDiscoverPage,
          toSwipePage: _toSwipePage,
        );
      } else if(_currentPage == Pages.discover) {
        return ExplorePage(
          toMyProfilePage: _toMyProfilePage,
          toSwipePage: _toSwipePage,
        );
      } else if (_currentPage == Pages.test) {
        return LoadTest();
      } else {
        return ErrorPage(toHomePage: _toSwipePage,);
      }
    }
  }
}