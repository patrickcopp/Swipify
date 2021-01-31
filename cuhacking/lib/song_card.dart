import 'package:flutter/material.dart';

class SongCard extends StatefulWidget {
  const SongCard(
  {Key key,
  this.color = Colors.indigo,
  this.trackTitle = "Card Example",
  this.imageUrl = "none",
  this.URI = ""})
  : super(key: key);
  final Color color;
  final String trackTitle;
  final String imageUrl;
  final String URI;

  @override
  _SongCardState createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print("Container clicked");
      },
      child: new Container(
      height: 450,
      width: 320,

      // Warning: hard-coding values like this is a bad practice
      padding: EdgeInsets.all(38.0),
      decoration: BoxDecoration(
        color: this.widget.color,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 7.0,
          color: Colors.transparent.withOpacity(1),
        ),
      ),

      child: new Column(children: [
        Text(
          this.widget.trackTitle,
          style: TextStyle(
            fontSize: 18.0,
            // color: Colors.white,
            color: Colors.black12.withOpacity(0.8),
            fontWeight: FontWeight.w900,
          ),
        ),
        new Image.network(this.widget.imageUrl)
      ]),
      ),
    );
  }
}
