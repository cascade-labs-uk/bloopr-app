import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:blooprtest/config.dart';

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
          icon: Icon(
            Icons.arrow_back,
            color: Constants.INACTIVE_COLOR_DARK,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Push Notifications'),
        backgroundColor: Constants.SECONDARY_COLOR,
        elevation: 0.0,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: 'Contact Email',
                subtitle: 'report@bloopr.org',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}