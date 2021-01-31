import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_sdk/spotify_sdk.dart';


class SongCard extends StatefulWidget {
  const SongCard(
  {Key key,
  this.color = Colors.indigo,
  this.trackTitle = "Card Example",
  this.imageUrl = "none",
  this.URI = "",
  this.artist=""})
  : super(key: key);
  final Color color;
  final String trackTitle;
  final String imageUrl;
  final String URI;
  final String artist;

  @override
  _SongCardState createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  var PAUSED = false;
  @override
  Widget build(BuildContext context) {
    this.play();
    return GestureDetector(
      onTap: (){
        this.PAUSED ? resume():pause();
        this.PAUSED =! this.PAUSED;
      },
      child: new Container(
      height: 400,
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

      child: new Column(children: [
        Text(
            this.widget.trackTitle, style: GoogleFonts.oswald(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 23),),
        ),
        new Padding(padding: EdgeInsets.only(top: 3),),
        new Image.network(this.widget.imageUrl),
        new Padding(padding: EdgeInsets.only(top: 3),),
        Text(
          this.widget.artist, style: GoogleFonts.oswald(textStyle: TextStyle(color: Colors.black, letterSpacing: .5, fontSize: 20),),
        ),
      ]),
      ),
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

