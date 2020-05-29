import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'personal_information_settings.dart';
import 'notifications_settings.dart';
import 'saved_posts_settings.dart';
import 'language_settings.dart';
import 'stats_settings.dart';
import 'package:blooprtest/auth.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/profile_pages/edit_profile_page.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({this.auth, this.onSignedOut, this.userFirestoreID});

  final Auth auth;
  final VoidCallback onSignedOut;
  final String userFirestoreID;

  void _signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
      // TODO: add widget on signed out
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back_ios,
              size: 22.5,
          ),
          color: Constants.INACTIVE_COLOR_DARK,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Settings',
          style: Constants.TEXT_STYLE_HEADER_DARK,
        ),
        backgroundColor: Constants.SECONDARY_COLOR,
        elevation: 0.0,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Account',
            tiles: [
              SettingsTile(
                title: 'Personal Information',
                leading: Icon(Icons.account_circle),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          PersonalInformation()));
                },
              ),
              SettingsTile(
                title: 'View Statistics',
                leading: Icon(Icons.show_chart),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (BuildContext context) => StatsPage(userFirestoreID: userFirestoreID,)
                      )
                  );
                },
              ),
//              SettingsTile(
//                title: 'Connect With Friends',
//                leading: Icon(Icons.person_add),
//                onTap: () {},
//              ),
              SettingsTile(
                title: 'Edit Profile',
                leading: Icon(Icons.person),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => EditProfilePage(firestoreID: userFirestoreID,)
                    )
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'General',
            tiles: [
              SettingsTile(
                title: 'Offline Browsing',
                subtitle: 'Coming Soon',
                leading: Icon(Icons.offline_pin),
                onTap: () {},
              ),
              SettingsTile(
                title: 'Notifications',
                leading: Icon(Icons.notifications),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => Notifications()));
                },
              ),
//              SettingsTile(
//                title: 'Saved Posts',
//                leading: Icon(Icons.bookmark),
//                onTap: () {
//                  Navigator.of(context).push(MaterialPageRoute(
//                      builder: (BuildContext context) => SavedPosts()));
//                },
//              ),
              SettingsTile(
                title: 'Language',
                leading: Icon(Icons.language),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => Language()));
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Privacy and Usage',
            tiles: [
              SettingsTile(
                title: 'Privacy Policy',
                leading: Icon(Icons.assignment_ind),
                onTap: () {
                  privacyPolicy();
                },
              ),
              SettingsTile(
                title: 'Terms of Use',
                leading: Icon(Icons.assignment),
                onTap: () {
                  termsOfUse();
                },
              ),
              SettingsTile(
                title: 'Community Guidelines',
                leading: Icon(Icons.people),
                onTap: () {
                  communityGuidelines();
                },
              ),
              SettingsTile(
                title: 'Copyright Policy',
                leading: Icon(Icons.copyright),
                onTap: () {
                  copyrightPolicy();
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Support',
            tiles: [
              SettingsTile(
                title: 'Report a Problem',
                leading: Icon(Icons.report),
                onTap: () {},
              ),
//              SettingsTile(
//                title: 'Safety and Security',
//                leading: Icon(Icons.security),
//                onTap: () {
//                  safetyAndSecurity();
//                },
//              ),
            ],
          ),
          SettingsSection(
            title: '',
            tiles: [
//              SettingsTile(
//                title: 'Add Account',
//                leading: Icon(Icons.language),
//                onTap: () {},
//              ),
              SettingsTile(
                title: 'Log Out',
                leading: Icon(Icons.exit_to_app),
                onTap: () {
                  auth.signOut();
                  onSignedOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

privacyPolicy() async {
  const url = "http://geneticlly.com/privacypolicy.html";
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true); //forceWebView
  } else {
    throw 'Could not launch $url';
  }
}

termsOfUse() async {
  const url = "http://bloopr.org";
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true); //forceWebView
  } else {
    throw 'Could not launch $url';
  }
}

communityGuidelines() async {
  const url = "http://bloopr.org";
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true); //forceWebView
  } else {
    throw 'Could not launch $url';
  }
}

copyrightPolicy() async {
  const url = "http://bloopr.org";
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true); //forceWebView
  } else {
    throw 'Could not launch $url';
  }
}

safetyAndSecurity() async {
  const url = "http://bloopr.org";
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true); //forceWebView
  } else {
    throw 'Could not launch $url';
  }
}