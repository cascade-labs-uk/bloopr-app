import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blooprtest/backend.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:blooprtest/config.dart';

class UploadProfilePicture extends StatefulWidget {
  UploadProfilePicture({this.fromCamera = true});

  BaseBackend backend = new Backend();
  final bool fromCamera;

  @override
  _UploadProfilePictureState createState() => _UploadProfilePictureState();
}

class _UploadProfilePictureState extends State<UploadProfilePicture> {

  File selectedImage;
  File croppedImage;
  bool imageSelectionOpenedOnce = false;
  bool openedCropOnce = false;

  Future cropImage() async {
    File newCroppedImage = await ImageCropper.cropImage(
      cropStyle: CropStyle.circle,
      sourcePath: selectedImage.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Constants.SECONDARY_COLOR,
          toolbarWidgetColor: Constants.OUTLINE_COLOR,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true
      ),
      iosUiSettings: IOSUiSettings(
          title: 'Cropper',
          rectX: 0,
          rectY: 0,
          rectWidth: 90,
          rectHeight: 100,
          aspectRatioLockEnabled: true
      )
    );

    setState(() {
      croppedImage = newCroppedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Constants.BACKGROUND_COLOR,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Constants.INACTIVE_COLOR_DARK,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Upload Profile Picture',
          style: Constants.TEXT_STYLE_HEADER_DARK,
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if(selectedImage == null) {
      if(!imageSelectionOpenedOnce) {
        setState(() {
          imageSelectionOpenedOnce = true;
        });
        if(widget.fromCamera) {
          getImageFromCamera();
        } else {
          getImageFromGallery();
        }
      }
      return Center(
        child: Column(
          children: <Widget>[
            Spacer(flex: 5,),
            RaisedButton(
              child: Text('upload image from gallery'),
              onPressed: getImageFromGallery, // TODO: link to upload from gallery function
            ),
            Spacer(flex: 1,),
            RaisedButton(
              child: Text('upload image from camera'),
              onPressed: getImageFromCamera,
            ),
            Spacer(flex: 5,)
          ],
        ),
      );
    } else if(croppedImage == null) {
      if(!openedCropOnce) {
        setState(() {
          openedCropOnce = true;
        });
        cropImage();
      }
      return Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Image.file(
                  selectedImage,
                  fit: BoxFit.scaleDown,
                ),
              ),
              RaisedButton(
                child: Text('crop image'),
                onPressed: cropImage,
              )
            ],
          )
      );
    } else {
      return Center(
          child: Column(
            children: <Widget>[
              ClipRRect(
                child: Image.file(croppedImage),
                borderRadius: BorderRadius.circular(1000),
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)
                ),
                elevation: 1,
                color: Constants.SECONDARY_COLOR,
                child: Text('Upload new profile picture'),
                onPressed: () {
                  widget.backend.uploadProfilePicture(croppedImage);
                  Navigator.pop(context);
                },
              )
            ],
          )
      );
    }
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = image;
    });
  }

  Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      selectedImage = image;
    });
  }
}
