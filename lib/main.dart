import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:csv/csv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(SignUpApp());

final TextEditingController _firstNameTextController = TextEditingController();

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
      body: Center(
        child: Text('Welcome ' + _firstNameTextController.value.text +'!' , style: Theme.of(context).textTheme.headline2),
      ),
    );
  }
}

const kHtml = '''
<h1>Heading</h1>
<p>A paragraph with <strong>strong</strong> <em>emphasized</em> text.</p>
<ol>
  <li>List item number one</li>
  <li>
    Two
    <ul>
      <li>2.1 (nested)</li>
      <li>2.2</li>
    </ul>
  </li>
  <li>Three</li>
</ol>
<p>Google Form</p>
<iframe src="https://docs.google.com/forms/d/e/1FAIpQLSd6Dtfd4zdKWXrD1cMNJir7Nw5MKnbb_rXMu3D2cYyLx6k5lw/viewform?usp=pp_url&entry.1161099116=abc&entry.1502601717=def" width="560" height="315"></iframe>''';

class IframeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Hello Google Form'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: HtmlWidget(
            kHtml,
            webView: true,
          ),
        ),
      );
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _lastNameTextController = TextEditingController();
  final _usernameTextController = TextEditingController();

  double _formProgress = 0;

  void _showWelcomeScreen() {
    Navigator.of(context).pushNamed('/welcome');
  }
  void _showIframeScreen() {
    Navigator.of(context).pushNamed('/iframe');
  }
  void _showPhotoPageOne() {
    Navigator.of(context).pushNamed('/fotopageone');
  }
  void _showPhotoPageTwo() {
    Navigator.of(context).pushNamed('/fotopagetwo');
  }



  void _updateFormProgress() {
    var progress = 0.0;
    var controllers = [
      _firstNameTextController,
      _lastNameTextController,
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
    return Form(
      onChanged: _updateFormProgress, // NEW
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _formProgress),
          Text('Sign Up', style: Theme.of(context).textTheme.headline4),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _firstNameTextController,
              decoration: InputDecoration(hintText: 'First name'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _lastNameTextController,
              decoration: InputDecoration(hintText: 'Last name'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _usernameTextController,
              decoration: InputDecoration(hintText: 'Username'),
            ),
          ),
          FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: _formProgress == 1 ? _showWelcomeScreen : null, // UPDATED
            child: Text('Sign up'),
          ),
          FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: _formProgress == 1 ? _showPhotoPageOne: null, // UPDATED
            child: Text('Upload Photo One'),
          ),
          FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: _formProgress == 1 ? _showPhotoPageTwo: null, // UPDATED
            child: Text('Upload Photo Two'),
          ),
          FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: _formProgress == 1 ? _showIframeScreen: null, // UPDATED
            child: Text('Google User Form'),
          ),
        ],
      ),
    );
  }
}

class MyPhotoPageOne extends StatefulWidget {
  @override
  _MyPhotoPageOneState createState() => _MyPhotoPageOneState();
}

class _MyPhotoPageOneState extends State<MyPhotoPageOne> {
  File pickedImage;
  List<List<String>> textList=[];
  List<String> lineList=[];

  bool isImageLoaded = false;
  String text = "";

  Future pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.camera);
    print('DEBUG ImagePicker.pickImage One');
    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  Future readText() async {

    textList = [];
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
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
      text=text+csv;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
      children: <Widget>[
        SizedBox(height: 100.0),
        isImageLoaded
            ? Center(
                child: Container(
                    height: 200.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(pickedImage), fit: BoxFit.cover))),
              )
            : Container(),
        SizedBox(height: 10.0),
        RaisedButton(
          child: Text('Pick an image One'),
          onPressed: pickImage,
        ),
        SizedBox(height: 10.0),
        RaisedButton(
          child: Text('Read Text One'),
          onPressed: readText,
        ),
        Text(text)
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
  List<List<String>> textList=[];
  List<String> lineList=[];

  bool isImageLoaded = false;
  String text = "";

  Future pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.camera);
    print('DEBUG ImagePicker.pickImage Two ');
    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  Future readText() async {

    textList = [];
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
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
      text=text+csv;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
      children: <Widget>[
        SizedBox(height: 100.0),
        isImageLoaded
            ? Center(
                child: Container(
                    height: 200.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(pickedImage), fit: BoxFit.cover))),
              )
            : Container(),
        SizedBox(height: 10.0),
        RaisedButton(
          child: Text('Pick an image Two'),
          onPressed: pickImage,
        ),
        SizedBox(height: 10.0),
        RaisedButton(
          child: Text('Read Text Two'),
          onPressed: readText,
        ),
        Text(text)
      ],
    ));
  }
}