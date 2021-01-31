import 'package:flutter/material.dart';

class SongCard extends StatelessWidget {
  const SongCard({
    Key key,
    this.color = Colors.indigo,
    this.trackTitle = "Card Example",
    this.imageUrl = "none",
    this.songUri = "song"
  }) : super(key: key);
  final Color color;
  final String trackTitle;
  final String imageUrl;
  final String songUri;

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
          color: Colors.transparent.withOpacity(0.3),
        ),
      ),

      child: new Column(
        children: [
          Text(
        trackTitle,
        style: TextStyle(
          fontSize: 36.0,
          // color: Colors.white,
          color: Colors.black12.withOpacity(0.8),
          fontWeight: FontWeight.w900,
        ),
      ),
          new Image.network(imageUrl)
      ]
      ),
    );
  }
}
