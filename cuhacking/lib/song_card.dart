import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

const NORMAL_HEIGHT = 400.0;
const LONG_HEIGHT = 600.0;

class SongCard extends StatefulWidget {
  const SongCard(
  {Key key,
  this.color = Colors.indigo,
  this.trackTitle = "Card Example",
  this.imageUrl = "none",
  this.URI = "",
  this.artist="",
  this.songJson=null})
  : super(key: key);
  final Color color;
  final String trackTitle;
  final String imageUrl;
  final String URI;
  final String artist;
  final songJson;

  @override
  _SongCardState createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  var PAUSED = false;
  var isInfoCard = false;
  @override
  Widget build(BuildContext context) {
    this.play();
    return GestureDetector(
      onTap: (){
        this.PAUSED ? resume() : pause();
        this.PAUSED =! this.PAUSED;
      },
      onLongPress: () {
        setState(() {
          isInfoCard = !isInfoCard;
        });
      },
      child: buildCard(isInfoCard)
    );
  }

  Map<String, String> getAdditionalInformation(json) {
    Duration songDuration = Duration(milliseconds: json['duration_ms']);
    String explicit = json['explicit'] ? "explicit" : "not explicit";
    return {
      "duration": songDuration.toString(),
      "explicit": explicit
    };
  }

  Container buildCard(isInfoCard) {
    var additionalInfo = getAdditionalInformation(this.widget.songJson);
    return Container(
      height: isInfoCard ? LONG_HEIGHT : NORMAL_HEIGHT,
      width: 320,

      // Warning: hard-coding values like this is a bad practice
      padding: EdgeInsets.only(top: 3,bottom:3),
      decoration: BoxDecoration(
        color: Color(0xff1DB954),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 1.0,
          color: Colors.transparent.withOpacity(1),
        ),
      ),

      child: new Column(
          children: [
            Text(
              this.widget.trackTitle, style: GoogleFonts.oswald(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 23),),
            ),
            new Padding(padding: EdgeInsets.only(top: 3),),
            new Image.network(this.widget.imageUrl),
            new Padding(padding: EdgeInsets.only(top: 3),),
            Text(
              this.widget.artist, style: GoogleFonts.oswald(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 20),),
            ),
            if(isInfoCard)
              Text(this.widget.songJson["album"]["name"],
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 20),),
              ),
            if(isInfoCard)
              Row(children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text(
                    additionalInfo['duration'] + ", " + additionalInfo['explicit'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.oswald(
                      textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 20),),
                  ),
                ),
              ]),
      ]),
    );
  }



  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      print("FUCK: " + e.code + " " + e.message);
    } on MissingPluginException {
      print('not implemented');
    }
  }

  Future<void> resume() async {
    await SpotifySdk.resume();
  }
  Future<void> play() async {
    var _uri = "spotify:track:" + this.widget.URI;
    await SpotifySdk.play(spotifyUri: _uri);
  }
}

