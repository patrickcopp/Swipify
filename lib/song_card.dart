import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;

const NORMAL_HEIGHT = 400.0;
const LONG_HEIGHT = 525.0;

class SongCard extends StatefulWidget {
  const SongCard(
  {Key key,
  this.color = Colors.indigo,
  this.trackTitle = "Card Example",
  this.imageUrl = "none",
  this.URI = "",
  this.artist="",
  this.songJson,
  this.headers})
  : super(key: key);
  final Color color;
  final String trackTitle;
  final String imageUrl;
  final String URI;
  final String artist;
  final songJson;
  final headers;

  @override
  _SongCardState createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  var PAUSED = false;
  var isInfoCard = false;
  @override
  Widget build(BuildContext context) {
    this.play();
    return InkWell(
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
      "duration": songDuration.toString().substring(0,songDuration.toString().indexOf('.'))
    };
  }

  Container buildCard(isInfoCard) {
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
              buildInfoCard()
      ]),
    );
  }

  Future<Map<String, String>> getFeatures(id) async {
    var getFeatures = await http.get(
        'https://api.spotify.com/v1/audio-features/$id',
        headers: this.widget.headers);
    var features = jsonDecode(getFeatures.body);
    var dancability = features['danceability'] * 100.0;
    var energy = features['energy'] * 100.0;
    var acousticness = features['acousticness'] * 100.0;
    return {"dance" : '$dancability% Danceable', "energy": '$energy% Energetic', "acoustic": '$acousticness% Acoustic'};
  }

FutureBuilder buildInfoCard(){
    var json = this.widget.songJson;
  var additionalInfo = getAdditionalInformation(json);
  var features;
  return FutureBuilder(
      builder: (context, featuresSnapshot) {
        if ((featuresSnapshot.connectionState == ConnectionState.none ||
            featuresSnapshot.connectionState == ConnectionState.waiting) &&
            featuresSnapshot.data == null) {
          return Container();
        } else {
          features = featuresSnapshot.data;
        }
        return Column(children: [
          Text(this.widget.songJson["album"]["name"],
          textAlign: TextAlign.center,
          style: GoogleFonts.oswald(
            textStyle: TextStyle(
                color: Colors.black, letterSpacing: .5, fontSize: 20),),
        ),
          Column(children: <Widget>[
          Text(
            features['dance'],
            textAlign: TextAlign.center,
            style: GoogleFonts.oswald(
            textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 20),),
            ),
            Text(
              features['energy'],
              textAlign: TextAlign.center,
              style: GoogleFonts.oswald(
                textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 20),),
            ),
            Text(
              features['acoustic'],
              textAlign: TextAlign.center,
              style: GoogleFonts.oswald(
                textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 20),),
            ),
          ]),
        ]);
  },
      future: getFeatures(json['id']),
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

