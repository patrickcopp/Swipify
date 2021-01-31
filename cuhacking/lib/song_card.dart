import 'package:flutter/material.dart';

class SongCard extends StatelessWidget {
  const SongCard(
      {Key key,
      this.color = Colors.indigo,
      this.trackTitle = "Card Example",
      this.imageUrl = "none",
      this.URI = "",
      this.artist = ""})
      : super(key: key);
  final Color color;
  final String trackTitle;
  final String imageUrl;
  final String URI;
  final String artist;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      width: 320,

      // Warning: hard-coding values like this is a bad practice
      padding: EdgeInsets.all(38.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 7.0,
          color: Colors.transparent.withOpacity(1),
        ),
      ),

      child: new Column(children: [
        Text(
          trackTitle,
          style: TextStyle(
            fontSize: 18.0,
            // color: Colors.white,
            color: Colors.black12.withOpacity(0.8),
            fontWeight: FontWeight.w900,
          ),
        ),
        new Image.network(imageUrl),
        Text(
          artist,
          style: TextStyle(
            fontSize: 18.0,
            // color: Colors.white,
            color: Colors.black12.withOpacity(0.8),
            fontWeight: FontWeight.w900,
          ),
        ),
      ]),
    );
  }
}
