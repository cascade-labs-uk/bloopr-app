import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:blooprtest/config.dart';
import 'package:blooprtest/backend.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as imageLib;

class UploadMeme extends StatefulWidget {

  final BaseBackend backend = new Backend();

  @override
  _UploadMemeState createState() => _UploadMemeState();
}

class _UploadMemeState extends State<UploadMeme> {

  File selectedImage;
  File croppedImage;
  bool  openedCropOnce = false;
  final formKey = new GlobalKey<FormState>();
  TextEditingController captionController = new TextEditingController();
  TextEditingController tagController = new TextEditingController();

  Future cropImage() async {
    File newCroppedImage = await ImageCropper.cropImage(
      sourcePath: selectedImage.path,
      aspectRatio: CropAspectRatio(ratioX: 0.9,ratioY: 1),
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

  Future<File> waterMarkImage(File imageFile) async {
    String path = imageFile.path;
    print(path);
    var baseImage = imageLib.decodeImage(imageFile.readAsBytesSync());
    ByteData data = await rootBundle.load("assets/profile_image_placeholder.png");
    List<int> watermark = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var watermarkImage = imageLib.decodeImage(watermark);
    var waterMarkedImage = imageLib.drawImage(baseImage, watermarkImage);
    return File(path).writeAsBytes(imageLib.encodeJpg(waterMarkedImage));
  }

  void validateAndSubmit() {
    final form = formKey.currentState;
    if(form.validate()) {
      String caption = captionController.text;
      String tag = tagController.text;
      try {
//        waterMarkImage(croppedImage).then((file) {
//          widget.backend.uploadPost(file, caption,[tag]);
//          Navigator.pop(context);
//        });
        widget.backend.uploadPost(croppedImage, caption, [tag]);
        Navigator.pop(context);
      } catch (e, s) {
        Fluttertoast.showToast(msg: "error with upload");
        print(s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.SECONDARY_COLOR,
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
          'Upload Meme',
          style: Constants.TEXT_STYLE_HEADER_DARK,
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if(selectedImage == null) {
      return Center(
        child: Column(
          children: <Widget>[
            Spacer(flex: 5,),
            RaisedButton(
              child: Text('Upload image from gallery'),
              onPressed: getImageFromGallery, // TODO: link to upload from gallery function
            ),
            Spacer(flex: 1,),
            RaisedButton(
              child: Text('Upload image from camera'),
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
            Image.file(selectedImage),
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
            Image.file(croppedImage),
            Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: captionController,
                    decoration: InputDecoration(
                        labelText: 'Pick a username',
                        fillColor: Colors.white
                    ),
                    validator: (value) => value.isEmpty ? 'please add a caption' : null,
                  ),
                  TextFormField(
                    controller: tagController,
                    decoration: InputDecoration(
                        labelText: 'Tag',
                        fillColor: Colors.white
                    ),
                    validator: (value) => value.isEmpty ? 'please add a tag' : null,
                  ),
                ],
              ),
            ),
            RaisedButton(
              child: Text('upload meme'),
              onPressed: validateAndSubmit,
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
