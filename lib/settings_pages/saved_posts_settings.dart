import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

void main() {
  return runApp(
    MaterialApp(
      home: SavedPosts(),
    ),
  );
}

class SavedPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          iconSize: 22.5,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Push Notifications'),
        backgroundColor: Colors.grey[500],
        elevation: 0.0,
      ),
      body: Center(
        child: Text('3 x n list of saved posts'),
      ),
    );
  }
}