import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

void main() {
  return runApp(
    MaterialApp(
      home: Notifications(),
    ),
  );
}

class Notifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Push Notifications'),
        backgroundColor: Colors.grey[500],
        elevation: 0.0,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: 'Notifications',
                subtitle: 'On',
                onTap: () {},
              ),
            ],
          ),
          SettingsSection(
            title: 'Interactions',
            tiles: [
              SettingsTile.switchTile(
                title: 'Swipes',
                switchValue: true,
                onToggle: (bool value) {},
              ),
              SettingsTile.switchTile(
                title: 'Comments',
                switchValue: true,
                onToggle: (bool value) {},
              ),
              SettingsTile.switchTile(
                title: 'New Followers',
                switchValue: true,
                onToggle: (bool value) {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}