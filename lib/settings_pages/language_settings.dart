import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

void main() {
  return runApp(
    MaterialApp(
      home: Language(),
    ),
  );
}

class Language extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 27.5,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Language'),
        backgroundColor: Colors.grey[500],
        elevation: 0.0,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: 'Language',
                subtitle: 'English',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}