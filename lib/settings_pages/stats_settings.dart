import 'package:blooprtest/backend.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

void main() {
  return runApp(
    MaterialApp(
      home: StatsPage(),
    ),
  );
}

class StatsPage extends StatefulWidget {
  StatsPage({this.userFirestoreID});

  final String userFirestoreID;
  final BaseBackend backend = new Backend();

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int rightSwipes;
  int leftSwipes;

  @override
  void initState() {
    super.initState();

    widget.backend.getUser(widget.userFirestoreID).then((userDocument) {
      setState(() {
        rightSwipes = userDocument.data["right swipes"];
        leftSwipes = userDocument.data["left swipes"];
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
        title: Text('Stats'),
        backgroundColor: Colors.grey[500],
        elevation: 0.0,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: 'Right Swipes',
                subtitle: rightSwipes==null?'loading':'${rightSwipes.toString()}',
                onTap: () {},
              ),
              SettingsTile(
                title: 'Left Swipes',
                subtitle: rightSwipes==null?'loading':'${leftSwipes.toString()}',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
