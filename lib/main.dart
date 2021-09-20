import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
typedef Fn = void Function();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Audio Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Audio Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // [example reference](https://github.com/Canardoux/tau/blob/master/flutter_sound/example/lib/recorder_onProgress/recorder_onProgress.dart)
  // [codec support](https://tau.canardoux.xyz/guides_codec.html)
  final Codec _codec = Codec.aacMP4;
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer _myPlayer = FlutterSoundPlayer();
  String _mPath = 'audio.mp4';
  bool _mPlayerIsInited = false;

  @override
  void initState() {
    try {
      this.checkEnvironment(_codec);
      Future(() async {
        // file inside /data/user/0/com.example.flutter_sound_app in android
        final directory = await getApplicationDocumentsDirectory();
        _mPath = "${directory.path}/audio.mp4";
        await _myPlayer.openAudioSession();
      });
      _mPlayerIsInited = true;
    }catch(e) {
      //TODO:  show alert and pop to previous screen
      print('err');
    }
    super.initState();
  }

  @override
  void dispose() {
    _mRecorder.closeAudioSession();
    _mRecorder = null;
    _myPlayer.closeAudioSession();
    _myPlayer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: executeRecording(_mRecorder), child: Text(_mRecorder.isRecording ? 'stop recording' : 'start recording')),
            ElevatedButton(onPressed: executePlay(_myPlayer), child: Text(_myPlayer.isPlaying ? 'stop playing audio' : 'start play audio'),),
            ElevatedButton(onPressed: executeArchieve, child: Text('archieve zip'),)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /*
  * MP4をサポートしている端末のみ有効とする
  * */
  checkEnvironment(Codec codec) async{
    await _mRecorder.openAudioSession();
    if (await _mRecorder.isEncoderSupported(codec)) {
      // ok
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
      ].request();
      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        return;
      }
    }else{
      // コーデックサポート外の端末の場合
      throw Exception('unsupported device');
    }
  }

  /*
  * 録音処理
  * */
  Fn executeRecording(FlutterSoundRecorder recorder){
    return recorder.isStopped
        ? () {
      record(recorder);
    }
        : () {
      stopRecorder(recorder).then((value) => setState(() {}));
    };
  }

  void record(FlutterSoundRecorder recorder) async {
    await recorder.startRecorder(codec: _codec, toFile: _mPath, sampleRate: 44100).catchError((err) {

    });
    setState(() {});
  }

  Future<void> stopRecorder(FlutterSoundRecorder recorder) async {
    await recorder.stopRecorder();
  }

  /*
  * 再生処理
  * */
  Fn executePlay(FlutterSoundPlayer player) {
    return player.isPlaying
        ? () {
      stopAudio(player);
    }
        : () {
      playAudio(_myPlayer).then((value) => setState(() {}));
    };
  }

  playAudio(FlutterSoundPlayer player) async {
    await _myPlayer.startPlayer(
        fromURI: _mPath,
        codec: _codec,
        whenFinished: (){setState((){});}
    );
    setState(() {});
  }

  stopAudio(FlutterSoundPlayer player) async {
    _myPlayer.stopPlayer();
  }

  executeArchieve () {
    try {
      Future(() async {
        final directory = await getApplicationDocumentsDirectory();
        final zipFile = File("${directory.path}/audio.zip");
        ZipFile.createFromFiles(sourceDir: directory, files: [
          File("${directory.path}/audio.mp4")
        ], zipFile: zipFile);
      });
    } catch (e) {
      print(e);
    }
  }
}
