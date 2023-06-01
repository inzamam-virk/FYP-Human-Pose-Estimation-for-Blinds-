import 'package:avatar_glow/avatar_glow.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// import 'nlp_detector_views/entity_extraction_view.dart';
// import 'nlp_detector_views/language_identifier_view.dart';
// import 'nlp_detector_views/language_translator_view.dart';
// import 'nlp_detector_views/smart_reply_view.dart';
// import 'vision_detector_views/barcode_scanner_view.dart';
// import 'vision_detector_views/digital_ink_recognizer_view.dart';
// import 'vision_detector_views/face_detector_view.dart';
// import 'vision_detector_views/label_detector_view.dart';
// import 'vision_detector_views/object_detector_view.dart';
import 'vision_detector_views/pose_detector_view.dart';
// import 'vision_detector_views/selfie_segmenter_view.dart';
// import 'vision_detector_views/text_detector_view.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Human Pose Estimation'),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PoseDetectorView()),
          );
        },
        // onDoubleTap: () async {
        //   await Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => Speaking()),
        //   );
        // },
        child: Container(
          color: Colors.white,
          child: Center(
            child: Text(
              "Tap to open camera\n\n\n",
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class Speaking extends StatefulWidget {
  const Speaking({key});

  @override
  State<Speaking> createState() => _SpeakingState();
}

class _SpeakingState extends State<Speaking> {
  final Map<String, HighlightedWord> _highlights = {
    'Highlight': HighlightedWord(
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'Impaired': HighlightedWord(
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  late stt.SpeechToText _speech;
  bool _isListening = true;
  String _text = 'Press the button and start speaking';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    _listen();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        // child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        child: FloatingActionButton(
          onPressed: _stopListen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          "Human Pose Estimation",
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: TextHighlight(
            text: _text,
            words: _highlights,
            textStyle: const TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (_isListening) {
      final bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {});
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    }
  }

  void _stopListen() {
    setState(() => _isListening = false);
    _speech.stop();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PoseDetectorView()));
  }
}




// class CustomCard extends StatelessWidget {
//   final String _label;
//   final Widget _viewPage;
//   final bool featureCompleted;

//   const CustomCard(this._label, this._viewPage, {this.featureCompleted = true});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5,
//       margin: EdgeInsets.only(bottom: 10),
//       child: ListTile(
//         tileColor: Theme.of(context).primaryColor,
//         title: Text(
//           _label,
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         onTap: () {
//           if (!featureCompleted) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content:
//                     const Text('This feature has not been implemented yet')));
//           } else {
//             Navigator.push(
//                 context, MaterialPageRoute(builder: (context) => _viewPage));
//           }
//         },
//       ),
//     );
//   }
// }
