import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Wu Family Ping Pong Scoreboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScoreboardPage(
          title: 'The Wu Family Ping Pong Scoreboard'
      ),
    );
  }
}

class ScoreboardPage extends StatefulWidget {
  ScoreboardPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ScoreboardPageState createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  int _teamOneCounter = 0;
  int _teamTwoCounter = 0;
  String _teamOneName = 'TEAM ONE';
  String _teamTwoName = 'TEAM TWO';
  TextEditingController _controllerForTeamOne;
  TextEditingController _controllerForTeamTwo;
  bool isDisabled = false;
  FlutterTts flutterTts = FlutterTts();

  void initState() {
    super.initState();
    _controllerForTeamOne = TextEditingController();
    _controllerForTeamOne.text = _teamOneName;

    _controllerForTeamTwo = TextEditingController();
    _controllerForTeamTwo.text = _teamTwoName;
  }

  void dispose() {
    _controllerForTeamOne.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontSize: 20)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          teamOneName(),
          createCounter(true),
          SizedBox(height: 50),
          teamTwoName(),
          createCounter(false),
          SizedBox(height: 100),
          resetButton(),
        ],
      ),
    );
  }

  SizedBox teamOneName() {
    return SizedBox(
        width: 300,
        child: TextField(
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
          ),
          controller: _controllerForTeamOne,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
          onSubmitted: (String value) {
            _teamOneName = value;
          },
        ),
      );
  }

  SizedBox teamTwoName() {
    return SizedBox(
      width: 300,
      child: TextField(
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
        ),
        controller: _controllerForTeamTwo,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
        onSubmitted: (String value) {
          _teamTwoName = value;
        },
      ),
    );
  }

  Widget createCounter(bool isTeamOne) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createCounterButton('-', isTeamOne, false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(isTeamOne ? _teamOneCounter.toString() : _teamTwoCounter.toString(), style: TextStyle(fontSize: 75)),
        ),
        createCounterButton('+', isTeamOne, true)
      ]
    );
  }

  Widget createCounterButton(String label, bool isTeamOne, bool shouldAdd) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 20, 10.0, 10.0),
      child: SizedBox(
            width: 100,
            height: 100,
            child: RaisedButton(
              child: Text(label, style: TextStyle(fontSize: 75, color: Colors.white)),
              color: Colors.blue,
              onPressed: isDisabled ? null : () async {
                if (!shouldAdd) {
                  if (isTeamOne && _teamOneCounter == 0 || !isTeamOne && _teamTwoCounter == 0) {
                    return null;
                  }
                }

                await flutterTts.setLanguage("en-GB");
                await flutterTts.setVolume(1.0);
                await flutterTts.isLanguageAvailable("en-GB");
                await flutterTts.setSpeechRate(0.5);

                setState(() {
                  if (shouldAdd) {
                    isTeamOne ? _teamOneCounter++ : _teamTwoCounter++;
                  } else {
                    isTeamOne ? _teamOneCounter-- : _teamTwoCounter--;
                  }

                  announceTeamPoints();

                  isDisabled = true;

                  Timer(Duration(seconds: 3),() {
                    setState( () {
                      isDisabled = false;
                    });
                  });

                });



                checkWinner();
              },
            ),
          ),
    );
  }

  void announceTeamPoints() {
    String pointsForTeamOne = 'points';
    String pointsForTeamTwo = 'points';

    if (_teamOneCounter == 1) {
      pointsForTeamOne = 'point';
    }

    if (_teamTwoCounter == 1) {
      pointsForTeamTwo = 'point';
    }

    flutterTts.speak('$_teamOneName has $_teamOneCounter $pointsForTeamOne. $_teamTwoName has $_teamTwoCounter $pointsForTeamTwo.');
  }

  void checkWinner() {
    if (_teamOneCounter >= 21 || _teamTwoCounter >= 21) {
      String winner;
      if (_teamOneCounter - _teamTwoCounter >= 2) {
        winner = _teamOneName;
      } else if (_teamTwoCounter - _teamOneCounter >= 2) {
        winner = _teamTwoName;
      }

      if (winner != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                title: Text('$winner WINS!'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('NEXT GAME'),
                    onPressed: () {
                      Navigator.of(context).pop();

                      setState(() {
                        _teamOneCounter = 0;
                        _teamTwoCounter = 0;
                      });
                    },
                  )
                ]
            )
        );
      }
    }
  }

  Widget resetButton() {
    return SizedBox(
      height: 50,
      child: RaisedButton(
        child: Text('RESET SCORES', style: TextStyle(fontSize: 25)),
        onPressed: () {
          setState(() {
            _teamOneCounter = 0;
            _teamTwoCounter = 0;
          });
        }
      ),
    );
  }
}
