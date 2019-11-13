import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intern/models/user.dart';
import 'package:intern/repo/db_creator.dart';
import 'package:intern/repo/service.dart';
import 'package:sqflite/sqlite_api.dart';

void main() async {
  await DBCreator().initDB();
  runApp(MaterialApp(
    title: 'intern',
    home: Home(),
  ));
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: ListView(
        children: <Widget>[
          RaisedButton(
            child: Text('Genrate Orders'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FirstScreen()));
            },
          ),
          RaisedButton(
            child: Text('Previous Orders'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SecondScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Order'),
      ),
      body: CustomForm(),
    );
  }
}

class CustomForm extends StatefulWidget {
  @override
  _CustomFormState createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormState>();
  Position _currentPosition;
  File _image;
  final _userName = TextEditingController();
  int id;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        //  crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _userName,
            decoration: InputDecoration(hintText: 'User Name'),
            validator: (value) {
              if (value.isEmpty) {
                return 'enter some text';
              }
              print(value);
              return null;
            },
          ),
          RaisedButton(
            onPressed: getLocation,
            child: Text('location'),
          ),
          if (_currentPosition != null)
            Text(
                'Location lat ${_currentPosition.latitude} long ${_currentPosition.longitude}'),
          RaisedButton(
            onPressed: () => getImage(ImageSource.gallery),
            child: Text('image'),
          ),
          if (_image != null) Image.file(_image),
          RaisedButton(
            child: Text('save'),
            onPressed: save,
          )
        ],
      ),
    );
  }

  getLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
    // print(position);
  }

  getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    setState(() {
      _image = croppedFile;
    });
  }

  save() async {
    print(_userName.text);
    print(
        "lat ${_currentPosition.latitude} long ${_currentPosition.longitude}");
    const base64 = const Base64Codec();
    List<int> imageBytes = _image.readAsBytesSync();
    print(imageBytes);
    final im = base64.encode(imageBytes);
    print(base64.encode(imageBytes));

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      int count = await UserService.usersCount();
      final user = User(count, _userName.text, _currentPosition.latitude,
          _currentPosition.longitude, im);
      await UserService.addUser(user);
      setState(() {
        id = count;
      });
      Navigator.pop(context);
    }
  }
}

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  Future<List<User>> users;

  @override
  void initState() {
    super.initState();
    users = UserService.getAllUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Orders'),
      ),
      body: ListView(
        children: <Widget>[
          FutureBuilder<List<User>>(
            future: users,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    children:
                        snapshot.data.map((user) => buildItem(user)).toList());
              }else {
                return SizedBox();
              }
            },
          )
        ],
      ),
    );
  }

  allPrevOrders() {
    users.then((user) => {print(user)}).catchError((e) => {print(e)});
  }

  Card buildItem(User user) {

    return Card(
      child: Column(
        children: <Widget>[
          Text('${user.id}'),
          Text('${user.userName}'),
          Text('${user.lat}'),
          Text('${user.long}'),
          Image.memory(
            base64Decode(user.img)
          )
          // Text('${user.img}'),
        ],

      ),
    );
  }
}

// class SecondScreen extends StatelessWidget {
//   List<User> users;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Previous Orders'),
//       ),
//     );
//   }
// }
