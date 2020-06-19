import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:csv/csv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(SignUpApp());

final TextEditingController _firstNameTextController = TextEditingController();
final TextEditingController _lastNameTextController = TextEditingController();
final TextEditingController _usernameTextController = TextEditingController();
final TextEditingController _truckIdTextController = TextEditingController()
  ..text = "TRUCK-ID-0001";
final TextEditingController _parkingIdTextController = TextEditingController()
  ..text = "PARKING-ID-001";
String code = '<ol> <li>Truck ID:' +
    _truckIdTextController.value.text +
    ' </li> <li>Parking ID:' +
    _parkingIdTextController.value.text +
    ' </li> </ol>';

class SignUpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => SignUpScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/iframe': (context) => IframeScreen(),
        '/fotopageone': (context) => MyPhotoPageOne(),
        '/fotopagetwo': (context) => MyPhotoPageTwo(),
      },
    );
  }
}

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: SignUpForm(),
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localisation des camions'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Welcome ' + _usernameTextController.value.text,
                style: Theme.of(context).textTheme.headline2),
            Text('please take a photo of truck ID ad parking ID',
                style: Theme.of(context).textTheme.headline6),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed('/fotopageone');
              },
              child: Text('Suivant',
                    style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String userName = '<h1>Verify Data</h1>' +
    '<p>User name<h3><strong>' +
    _usernameTextController.value.text +
    '</strong></h3>' +
    'Parking details</p>';

String iframe =
    '<iframe src="https://docs.google.com/forms/d/e/1FAIpQLSdM4R3KDmlsSzTAW5YT3heQ6GlmbCoeWU_epsfVm_LJX5AWoA/viewform?usp=pp_url&entry.1252875767=' +
        _parkingIdTextController.value.text +
        '&entry.1016685718=' +
        _truckIdTextController.value.text +
        '" width="560" height="915"></iframe>';

String kHtml = iframe;

class IframeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Localisation des camions'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: HtmlWidget(
            kHtml,
            webView: true,
          ),
        ),
        drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          ListTile(
            title: Text('Nouveau camion'),
            onTap: () {
              Navigator.of(context).pushNamed('/');
            },
          ),
          ListTile(
            title: Text('Exit'),
            onTap: () {
              SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
            },
          ),
        ])),
      );
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  double _formProgress = 0;

  void _showWelcomeScreen() {
    Navigator.of(context).pushNamed('/welcome');
  }

  void _updateFormProgress() {
    var progress = 0.0;
    var controllers = [
      //  _firstNameTextController,
      //  _lastNameTextController,
      _usernameTextController
    ];

    for (var controller in controllers) {
      if (controller.value.text.isNotEmpty) {
        progress += 1 / controllers.length;
      }
    }

    setState(() {
      _formProgress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Localisation des camions'),
        ),
        body: Center(
          child: Form(
          onChanged: _updateFormProgress, // NEW
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: _formProgress, 
                backgroundColor: Colors.white,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Image.asset('assets/images/petit-forestier.png'),
                      padding: const EdgeInsets.only(left: 5,right: 5),
                      margin: const EdgeInsets.all(10),
                    ) 
                  ),
                  Expanded(
                    child: Container(
                      child: Image.asset('assets/images/logo-lecapitaine.png'),
                      margin: const EdgeInsets.all(20),
                    ) 
                  ),
                ],
              ),
              Container(
                    child: RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/fotopageone');
                      },
                      child: Text('Nouveau camion',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    margin: const EdgeInsets.only(top: 150),
                    height: 70,
                    width: 300,
                  ),
            ],
          ),
        )));
  }
}

class MyPhotoPageOne extends StatefulWidget {
  @override
  _MyPhotoPageOneState createState() => _MyPhotoPageOneState();
}

class _MyPhotoPageOneState extends State<MyPhotoPageOne> {
  File pickedImage;
  List<List<String>> textList = [];
  List<String> lineList = [];

  bool isImageLoaded = false;
  String text = "";

  Future pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.camera);
    print('DEBUG ImagePicker.pickImage One');

    readText(tempStore);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  Future readText(File tempStore) async {
    textList = [];
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(tempStore);
    print('DEBUG Firevision Image one 10');
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);
    print('DEBUG Firevision readText One Image 20');
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          lineList.add(word.text);
        }
        textList.add(lineList);
        lineList = [];
      }
    }

    String csv = const ListToCsvConverter().convert(textList);
    print(csv);
    setState(() {
      text = text + csv;
      text.replaceAll(",-,", "-");
      text.replaceAll(",-", "-");
      text.replaceAll("-,", "-");

      _truckIdTextController.text = text;
      code = '<ol> <li>Truck ID:' +
          _truckIdTextController.value.text +
          ' </li> <li>Parking ID:' +
          _parkingIdTextController.value.text +
          ' </li> </ol>';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Localisation des camions'),
        ),
        body: Column(
          children: <Widget>[
            Text("Scanner votre camion",style: TextStyle(fontSize: 20)),
            SizedBox(height: 100.0),
            isImageLoaded
                ? Center(
                    child: Container(
                        height: 200.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(pickedImage),
                                fit: BoxFit.cover))),
                  )
                : Container(),
            SizedBox(height: 10.0),
            RaisedButton(
              child: Text('Prendre une photo',style: TextStyle(fontSize: 20)),
              onPressed: (){
                pickImage();
              },
            ),
            SizedBox(height: 10.0),
            /*RaisedButton(
              child: Text('Read Truck ID',style: TextStyle(fontSize: 20)),
              onPressed: readText,
            ),*/
            //Text(text),
            TextFormField(
              controller: _truckIdTextController,
              decoration: InputDecoration(hintText: 'TRUCK-ID-0001'),
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed('/fotopagetwo');
              },
              child: Text('Suivant',
                    style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ));
  }
}

class MyPhotoPageTwo extends StatefulWidget {
  @override
  _MyPhotoPageStateTwo createState() => _MyPhotoPageStateTwo();
}

class _MyPhotoPageStateTwo extends State<MyPhotoPageTwo> {
  File pickedImage;
  List<List<String>> textList = [];
  List<String> lineList = [];

  bool isImageLoaded = false;
  String text = "";

  Future pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.camera);
    print('DEBUG ImagePicker.pickImage Two ');

    readText(tempStore);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  Future readText(File tempStore) async {
    textList = [];
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(tempStore);
    print('DEBUG Firevision Image Two 10');
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);
    print('DEBUG Firevision readText Image Two 20');
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          lineList.add(word.text);
        }
        textList.add(lineList);
        lineList = [];
      }
    }

    String csv = const ListToCsvConverter().convert(textList);
    print(csv);
    setState(() {
      text = text + csv;
      text.replaceAll(",-,", "-");
      text.replaceAll(",-", "-");
      text.replaceAll("-,", "-");

      _parkingIdTextController..text = text;
      code = '<ol> <li>Truck ID:' +
          _truckIdTextController.value.text +
          ' </li> <li>Parking ID:' +
          _parkingIdTextController.value.text +
          ' </li> </ol>';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Localisation des camions'),
        ),
        body: Column(
          children: <Widget>[
            Text("Scanner la place du parking",style: TextStyle(fontSize: 20)),
            SizedBox(height: 100.0),
            isImageLoaded
                ? Center(
                    child: Container(
                        height: 200.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(pickedImage),
                                fit: BoxFit.cover))),
                  )
                : Container(),
            SizedBox(height: 10.0),
            RaisedButton(
              child: Text('Prendre une photo',style: TextStyle(fontSize: 20)),
              onPressed:(){
                pickImage();
              }
            ),
            SizedBox(height: 10.0),
            /*RaisedButton(
              child: Text('Read Parking ID',style: TextStyle(fontSize: 20)),
              onPressed: readText,
            ),*/
            //Text(text),
            TextFormField(
              controller: _parkingIdTextController,
              decoration: InputDecoration(hintText: 'PARKING-ID-0001'),
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed('/iframe');
              },
              child: Text('Suivant',
                    style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ));
  }
}
