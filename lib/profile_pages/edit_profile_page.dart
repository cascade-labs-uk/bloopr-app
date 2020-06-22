import 'package:blooprtest/backend.dart';
import 'package:flutter/material.dart';
import 'package:blooprtest/backend.dart';
import 'package:blooprtest/upload_pages/upload_profile_picture.dart';
import 'package:blooprtest/config.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({this.firestoreID, this.reloadPageCallback});

  final String firestoreID;
  final VoidCallback reloadPageCallback;
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
    if(validateAndSave()) {
      widget.backend.updateProfile(
          nicknameTextController.text,
          bioTextController.text
      );
      widget.reloadPageCallback();
      Navigator.pop(context);
    }
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
        elevation: 0.8,
        title: Text(
          'Edit Profile',
          style: Constants.TEXT_STYLE_HEADER_DARK,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 22.5,
            color: Constants.DARK_TEXT,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Save',
              style: TextStyle(
                color: Constants.HIGHLIGHT_COLOR,
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
              ),
            ),
            onPressed: () {
              validateAndSubmit();
            },
          ),
        ],
      ),
      body: Container(
        color: Constants.BACKGROUND_COLOR,
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 32.5, 0, 0),
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Constants.OUTLINE_COLOR,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(100)
                    ),
                    child: ClipRRect(
                      child: ProfilePicture(widget.firestoreID),
                      borderRadius: BorderRadius.circular(75.0),
                    ),
                  ),
                  onTap: () {
                    openUploadProfilePicture(context, false);
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 17.5),
                child: FlatButton(
                  child: Text(
                    "Change Photo",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Constants.HIGHLIGHT_COLOR,
                    ),
                  ),
                  onPressed: () {
                    openUploadProfilePicture(context, false);
                  },
                ),
              ),
//              Padding(
//                padding: const EdgeInsets.fromLTRB(0,0,0,16.0),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                  children: <Widget>[
//                    RaisedButton(
//                      shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.circular(5.0),
//                          side: BorderSide(
//                            color: Constants.DARK_TEXT,
//                            width: 0.5,
//                          )
//                      ),
//                      elevation: 0,
//                      color: Constants.BACKGROUND_COLOR,
//                      child: Text('Upload from camera'),
//                      onPressed: () {
//                        openUploadProfilePicture(context, true);
//                      },
//                    ),
//                    RaisedButton(
//                      shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.circular(5.0),
//                          side: BorderSide(
//                            color: Constants.DARK_TEXT,
//                            width: 0.5,
//                          )
//                      ),
//                      elevation: 0,
//                      color: Constants.BACKGROUND_COLOR,
//                      child: Text('Upload from gallery'),
//                      onPressed: () {
//                        openUploadProfilePicture(context, false);
//                      },
//                    ),
//                  ],
//                ),
//              ),
              Container(
                color: Constants.OUTLINE_COLOR,
                width: double.infinity,
                height: 0.5,
              ),
              Padding(
                padding: const EdgeInsets.all(2.5),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.5, 0, 8.0, 0),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[500],
                                    width: 0.0,
                                  ),
                                ),
                            ),
                            width: 280,
                            child: TextFormField(
                              controller: nicknameTextController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.5,0,8.0,0),
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
                        validator: (value) => value.length > 100 ? 'you are over the 100 character limit' : null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: 'Bio',
                          hintStyle: Constants.TEXT_STYLE_HINT_DARK,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.5),
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
