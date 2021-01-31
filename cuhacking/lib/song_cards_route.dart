import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:swipeable_card/swipeable_card.dart';
import 'package:http/http.dart' as http;

import 'song_card.dart';

class SongCardSlide extends StatefulWidget {
  const SongCardSlide({Key key}) : super(key: key);

  @override
  _SongCardRouteState createState() => _SongCardRouteState();
}

List<SongCard> cards;
String songUri;
bool isPlaying = false;

void setStatus(String code, {String message = ''}) {
  var text = message.isEmpty ? '' : ' : $message';
  print('$code$text');
}

Future<List<SongCard>> initCards(args) async {
  List<SongCard> _cards = new List<SongCard>();
  var resSong = await http.get('https://api.spotify.com/v1/tracks/60Ctoy2M8nmDaI7Fax3fTL', headers: args['headers']);
  var song = jsonDecode(resSong.body);
  songUri = song["uri"];
  for (int i = 0; i < 5; i++) {
    _cards.add(SongCard(color: Colors.white70, trackTitle: song["name"], imageUrl: song["album"]["images"][0]["url"], songUri: song["uri"],));
  }
  return _cards;
}

Future<void> play(songUri) async {
  try {
    await SpotifySdk.play(spotifyUri: songUri);
    isPlaying = true;
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}

Future<void> pause() async {
  try {
    await SpotifySdk.pause();
    isPlaying = false;
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}

class _SongCardRouteState extends State<SongCardSlide> {
  int currentCardIndex = 0;
  SwipeableWidgetController _cardController = SwipeableWidgetController();
  Widget projectWidget(args) {
    return FutureBuilder(
      builder: (context, cardsSnapshot) {
        if ((cardsSnapshot.connectionState == ConnectionState.none || cardsSnapshot.connectionState == ConnectionState.waiting) &&
            cardsSnapshot.data == null) {
          return Container();
        } else {
          cards = cardsSnapshot.data;
        }
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              if (currentCardIndex < cards.length)
                SwipeableWidgetSlide(
                  key: ObjectKey(currentCardIndex),
                  child: cards[currentCardIndex],
                  onLeftSwipe: () => swipeLeft(),
                  onRightSwipe: () => swipeRight(),
                  onTopSwipe: () => swipeTop(),
                  onBottomSwipe: () => swipeBottom(),
                  nextCards: <Widget>[
                    // show next card
                    // if there are no next cards, show nothing
                    if (!(currentCardIndex + 1 >= cards.length))
                      Align(
                        alignment: Alignment.center,
                        child: cards[currentCardIndex + 1],
                      ),
                  ],
                )
              else
              // if the deck is complete, add a button to reset deck
                Center(
                  child: ElevatedButton(
                    child: Text("Reset deck"),
                    onPressed: () => setState(() => currentCardIndex = 0),
                  ),
                ),
              Center(
                child: ElevatedButton(
                  child: Text("Play/Pause"),
                  onPressed: () {
                    isPlaying ? pause() : play(songUri);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.cyan, // background
                    onPrimary: Colors.white, // foreground
                  ),
                ),
              )
            ],
          ),
        );
      },
      future: initCards(args),
    );
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Songs'),
        automaticallyImplyLeading: true,
      ),
      body: projectWidget(args),
    );
  }

  void swipeLeft() {
    print("left");

    // NOTE: it is your job to change the card
    setState(() => currentCardIndex++);
  }

  void swipeRight() {
    print("right");
    setState(() => currentCardIndex++);
  }

  void swipeTop() {
    print("top");
    play(songUri);
    setState(() => currentCardIndex++);
  }

  void swipeBottom() {
    print("bottom");
    setState(() => currentCardIndex++);
  }
}
