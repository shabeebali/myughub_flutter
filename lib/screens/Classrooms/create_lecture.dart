import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CreateLecture extends StatefulWidget{
  @override
  CreateLectureState createState() {
    return CreateLectureState();
  }
}

class CreateLectureState extends State<CreateLecture>{

  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;
  TextEditingController questionController = new TextEditingController();
  late Duration positionController;
  String videoId = '';
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;
  List<LectureQuestion> questions = [];
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: '',
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
  }
  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              log('Settings Tapped!');
            },
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {},
      ),
      builder: (context, player) => Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
          ),
          title: const Text(
            'Add Lecture / Class',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          children: [
            player,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _space,
                  _text('Title', _videoMetaData.title),
                  _space,
                  _text('Duration', _printDuration(_videoMetaData.duration)),
                  _space,
                  TextField(
                    enabled: _isPlayerReady,
                    controller: _idController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter youtube \<video id\> or \<link\>',
                      labelText: 'Video ID / URL',
                      fillColor: Colors.blueAccent.withAlpha(20),
                      filled: true,
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.blueAccent,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _idController.clear(),
                      ),
                    ),
                  ),
                  _space,
                  Row(
                    children: [
                      _loadLoadButton(),
                    ],
                  ),
                  _space,
                ]
              ),
            ),

            Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: ScrollController(),
                  itemBuilder: (context, index) {
                    LectureQuestion _model = questions[index];
                    return Container(
                      child: Card(
                        color: Colors.white70,
                        child: Padding(
                          padding: EdgeInsets.only(left:16.0, right: 16.0, top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Question ${index + 1}',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                                  Text(_printDuration(_model.time), style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.w600),textAlign: TextAlign.right)
                                ],
                              ),
                              Text(_model.question, textAlign: TextAlign.left, style: TextStyle(fontSize: 16.0),),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      child: Text('EDIT'),
                                      onPressed: () {
                                        positionController = questions[index].time;
                                        questionController.text = questions[index].question;
                                        showQuestionDialog(mode: 'UPDATE', index: index);
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      child: Text('DELETE'),
                                      onPressed: (){
                                        showDialog(context: context, builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirm'),
                                            content: Text('Do you want to delete this question?'),
                                            actions: [
                                              TextButton(onPressed: (){
                                                Navigator.pop(context);
                                              }, child: Text('Cancel')),
                                              TextButton(onPressed: (){
                                                questions.removeAt(index);
                                                setState(() {});
                                                Navigator.pop(context);
                                              }, child: Text('Yes'))
                                            ],
                                          );
                                        });
                                      },
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: questions.length
                )
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: videoId != '' ? MaterialButton(
                  color: Colors.cyan.shade800,
                  onPressed: () {
                    _controller.pause();
                    positionController = _controller.value.position;
                    showQuestionDialog();
                  },
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Text(
                      'Add Question',
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ): null,
              ),
            ],
        ),
      ),
    );
  }
  showQuestionDialog({mode: 'CREATE', index}) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Set Question'),
        content: Container(
          width: 260.0,
          height: 230.0,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: const Color(0xFFFFFF),
            borderRadius: BorderRadius.all(new Radius.circular(32.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // dialog top
              Expanded(
                child: Row(
                  children: [
                    Container(
                      // padding: new EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: _text('Time Position', _printDuration(positionController))
                    ),
                  ],
                ),
              ),
              // dialog centre
              Expanded(
                child: Container(
                    child: TextField(
                      decoration: InputDecoration(
                          fillColor: Colors.blueAccent.withAlpha(20),
                          border: InputBorder.none,
                          filled: true,
                          contentPadding: EdgeInsets.only(left: 10.0,top: 10.0,bottom: 10.0,right: 10.0),
                          hintText: 'Enter Question here',
                          labelText: 'Question'
                      ),
                      maxLines: 8,
                      controller: questionController,
                    )
                ),
                flex: 2,
              ),
              // dialog bottom
              Expanded(
                  child: ElevatedButton(
                    child: mode == 'CREATE' ? Text('Add Question') : Text('Update Question'),
                    onPressed: () {
                      if(mode == 'CREATE') {
                        questions.add(new LectureQuestion(time: _controller.value.position, question: questionController.text));
                      } else {
                        questions[index].question = questionController.text;
                      }
                      questionController.clear();
                      setState(() {});
                      // print(questions);
                      Navigator.pop(context);
                    },
                  )
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget _text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _space => const SizedBox(height: 10);

  Widget _loadLoadButton() {
    return Expanded(
      child: MaterialButton(
        color: Colors.blueAccent,
        onPressed: _isPlayerReady
            ? () {
          if (_idController.text.isNotEmpty) {
            var id = YoutubePlayer.convertUrlToId(
              _idController.text,
            ) ??
                '';
              if(id != '') {
                setState(() {
                  videoId = id;
                });
              }
             _controller.load(id);
            FocusScope.of(context).requestFocus(FocusNode());
          } else {
            _showSnackBar('Source can\'t be empty!');
          }
        }
            : null,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            'LOAD',
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

class LectureQuestion {
  Duration time;
  String question;
  LectureQuestion({required this.time, required this.question});
}