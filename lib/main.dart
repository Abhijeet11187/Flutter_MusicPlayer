import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Music'),
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
  //Variables

  List<Song> _songAll;
  MusicFinder _musicFinder;
  Directory dir;
  File testFile;
  int _currentSongIndex;
  Duration _currentPosition;
  ByteData bytes;
  AudioPlayer audioPlayer = new AudioPlayer();
  bool _isMusicAvailable = false;

  @override
  void initState() {
    _getMusic();
    super.initState();
  }

// ************ Playing Audio (Calling Function to audioPlayer) ************

  Future _playLocal(String url) async {
    if (url == null) {
      print("Method is calling on Null");
    } else {
      playMusic(url);
      _music_Playing(context);
      // final result = await _musicFinder.play(url, isLocal: true);
    }
  }

// ************ Function to play Music using Plugin audioPlayer ************

  Future<void> playMusic(String kUrl) async {
    print("In the Play Music");

    await audioPlayer.play(kUrl);
    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      setState(() {
        _currentPosition = p;
        print(p);
      });
    });
  }

  // ************ Getting Music From Mobile Phone ************

  void _getMusic() async {
    MusicFinder _musicFinder = new MusicFinder();
    var songs = await MusicFinder.allSongs();
    setState(() {
      _songAll = songs;
      _isMusicAvailable = true;
    });
  }


  //Retruns Bottom Sheet While Music is running able to pause, resume,stop music

  Widget _music_Playing(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: 180,
            child: Column(
              children: <Widget>[
                Container(
                    height: 100, child: Image.asset("images/audioPlaying.gif")
                    ),
                Text(
                  _songAll[_currentSongIndex].title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      fontStyle: FontStyle.italic),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Reverse Song',
                      icon: Icon(Icons.replay_10),
                      onPressed: () async {
                        //Subtract 10 sec extra to current postion of song and pass to seek method
                        Duration _seekPosition =
                            _currentPosition - Duration(milliseconds: 1000);
                        await audioPlayer.seek(_seekPosition);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      tooltip: 'Stop',
                      onPressed: () async {
                        await audioPlayer.stop();
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      tooltip: 'Pause',
                      icon: Icon(Icons.pause),
                      onPressed: () async {
                        await audioPlayer.pause();
                      },
                    ),
                    IconButton(
                      tooltip: 'Resume',
                      icon: Icon(Icons.play_arrow),
                      onPressed: () async {
                        await audioPlayer.resume();
                        setState(() {});
                      },
                    ),
                    IconButton(
                      tooltip: 'Forward Song',
                      icon: Icon(Icons.forward_10),
                      onPressed: () async {
                        //Add 10 sec extra to current postion of song and pass to seek method
                        Duration _seekPosition =
                            _currentPosition + Duration(milliseconds: 1000);
                        await audioPlayer.seek(_seekPosition);
                      },
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Text(widget.title),
        ),
        body: _isMusicAvailable
            ? ListView.builder(
                itemCount: _songAll.length,
                itemBuilder: (context, int index) {
                  return ListTile(
                    onTap: () => {
                      _currentSongIndex = index,
                      _playLocal(_songAll[index].uri),
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.orangeAccent,
                      child: Image.asset('images/MusicIcon.png'),
                    ),
                    title: Text(_songAll[index].title),
                  );
                })
            : Center(child: Image.asset('images/waitPlease.gif'))
            );
  }
}
