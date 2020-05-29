import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:blooprtest/backend.dart';
import 'package:blooprtest/config.dart';

void main() {
  return runApp(
    MaterialApp(
      home: PersonalInformation(),
    ),
  );
}

class PersonalInformation extends StatefulWidget {
  PersonalInformation({this.userFirestoreID});

  final String userFirestoreID;
  final BaseBackend backend = new Backend();

  @override
  _PersonalInformationState createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  String userEmail;

  @override
  void initState() {
    super.initState();

    widget.backend.getOwnEmail().then((email) {
      setState(() {
        userEmail = email;
      });
    });
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Manage Profile'),
        backgroundColor: Constants.SECONDARY_COLOR,
        elevation: 0.0,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
//              SettingsTile(
//                title: 'Phone Number',
//                onTap: () {},
//              ),
              SettingsTile(
                title: 'Email',
                subtitle: userEmail==null?'loading':userEmail,
                onTap: () {},
              ),
//              SettingsTile(
//                title: 'Password',
//                onTap: () {},
//              ),
//              SettingsTile(
//                title: 'Save Login Information',
//                onTap: () {},
//              ),
            ],
          ),
        ],
      ),
    );
  }
}
