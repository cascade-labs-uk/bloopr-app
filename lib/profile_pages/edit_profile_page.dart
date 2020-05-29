import 'package:blooprtest/backend.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/backend.dart';
import 'package:blooprtest/upload_pages/upload_profile_picture.dart';
import 'package:blooprtest/config.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({this.firestoreID});

  final firestoreID;
  final BaseBackend backend = new Backend();

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final formKey = new GlobalKey<FormState>();
  TextEditingController nicknameTextController = new TextEditingController();
  TextEditingController bioTextController = new TextEditingController();

  bool validateAndSave() {
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() {
    widget.backend.updateProfile(
      nicknameTextController.text,
      bioTextController.text
    );
  }

  Future openUploadProfilePicture(context, bool fromCamera) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => UploadProfilePicture(fromCamera: fromCamera,)));
  }

  @override
  void initState() {
    super.initState();

    // TODO: potentially use preloaded information if this does not pose a security or data integrity risk
    widget.backend.getOwnFirestoreUserID().then((firestoreID) {
      widget.backend.getUser(firestoreID).then((userDocument) {
        setState(() {
          nicknameTextController.text = userDocument.data['nickname'];
          bioTextController.text = userDocument.data['user bio'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.SECONDARY_COLOR,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: Constants.TEXT_STYLE_HEADER_DARK,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 22.5,
            color: Constants.INACTIVE_COLOR_DARK,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Constants.BACKGROUND_COLOR,
        child: Form(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  child: ProfilePicture(widget.firestoreID),
                  borderRadius: BorderRadius.circular(75.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,0,0,16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: BorderSide(
                            color: Constants.DARK_TEXT,
                            width: 0.5,
                          )
                      ),
                      elevation: 0,
                      color: Constants.BACKGROUND_COLOR,
                      child: Text('Upload from camera'),
                      onPressed: () {
                        openUploadProfilePicture(context, true);
                      },
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: BorderSide(
                            color: Constants.DARK_TEXT,
                            width: 0.5,
                          )
                      ),
                      elevation: 0,
                      color: Constants.BACKGROUND_COLOR,
                      child: Text('Upload from gallery'),
                      onPressed: () {
                        openUploadProfilePicture(context, false);
                      },
                    ),
                  ],
                ),
              ),
              Container(
                color: Constants.OUTLINE_COLOR,
                width: double.infinity,
                height: 0.5,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0,0,8.0,0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Username',
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: nicknameTextController,
                        decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: Constants.TEXT_STYLE_HINT_DARK,
                            fillColor: Colors.white,
                        ),
                        validator: (value) => value.isEmpty ? 'nickname cannot be empty' : null,
                        //onSaved: (value) => _email = value,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0,0,8.0,0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Bio',
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        controller: bioTextController,
                        decoration: InputDecoration(
                          hintText: 'Bio',
                          hintStyle: Constants.TEXT_STYLE_HINT_DARK,
                          fillColor: Colors.white
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(
                        color: Constants.DARK_TEXT,
                        width: 0.5,
                      )
                  ),
                  elevation: 0,
                  color: Constants.BACKGROUND_COLOR,
                  child: Text('Done'),
                  onPressed: () {
                    validateAndSubmit();
                    Navigator.pop(context);
                  },
                ),
              ),
              Container(
                color: Constants.OUTLINE_COLOR,
                width: double.infinity,
                height: 0.5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder ProfilePicture(String userID) {
    return FutureBuilder(
      future: widget.backend.getProfilePicture(userID),
      builder: (context, snapshot) {
        Widget displayed;
        if(snapshot.hasData) {
          displayed = Image.memory(
            snapshot.data,
            height: 150,
            width: 150,
          );
        } else {
          displayed = Image.asset(
            'assets/profile_image_placeholder.png',
            height: 150,
            width: 150,
          );
        }

        return displayed;
      },
    );
  }
}
