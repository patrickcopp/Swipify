import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:swipeable_card/swipeable_card.dart';
import 'package:http/http.dart' as http;
import 'recommendations.dart';
import 'song_card.dart';

class SongCardSlide extends StatefulWidget {
  const SongCardSlide({Key key}) : super(key: key);

  @override
  _SongCardRouteState createState() => _SongCardRouteState();
}

var PAUSED = false;
var PLAYLIST_ID = "";
var HEADERS;
List<SongCard> cards = null;
var args;
String currentSong;

Future<List<SongCard>> initCards(args) async {
  if (cards != null && cards.length != 0) {
    return cards;
  }

  List<SongCard> _cards = new List<SongCard>();
  PLAYLIST_ID = args["playlistID"];
  HEADERS = args["headers"];
  var recommendedList = await getRecommendedTracks(HEADERS);

  for (int i = 0; i < recommendedList.length; i++) {
    _cards.add(SongCard(
        color: Colors.white70.withOpacity(1),
        trackTitle: recommendedList[i]["name"],
        imageUrl: recommendedList[i]["album"]["images"][0]["url"],
        URI: recommendedList[i]["id"],
        artist: recommendedList[i]["artists"][0]["name"],
    ));
  }
  return _cards;
}

void setStatus(String code, {String message = ''}) {
  var text = message.isEmpty ? '' : ' : $message';
  print('$code$text');
}

Future<void> play(songUri) async {
  currentSong = songUri;
  var _uri = "spotify:track:" + songUri;
  try {
    await SpotifySdk.play(spotifyUri: _uri);
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}

Future<void> pause() async {
  try {
    await SpotifySdk.pause();
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}

Future<void> resume() async {
  try {
    await SpotifySdk.resume();
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}

class _SongCardRouteState extends State<SongCardSlide> {
  int currentCardIndex = 0;
  Future initCardList;
  @override
  void initState() {
    initCardList = initCards(args);
  }

  SwipeableWidgetController _cardController = SwipeableWidgetController();
  Widget projectWidget(args) {
    return FutureBuilder(
      builder: (context, cardsSnapshot) {
        if ((cardsSnapshot.connectionState == ConnectionState.none ||
                cardsSnapshot.connectionState == ConnectionState.waiting) &&
            cardsSnapshot.data == null) {
          return Container();
        } else {
          cards = cardsSnapshot.data;
          if (currentCardIndex < cards.length) {
            play(cards[currentCardIndex].URI);
          }
        }
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              if (currentCardIndex < cards.length)
                SwipeableWidget(
                  key: ObjectKey(currentCardIndex),
                  child: cards[currentCardIndex],
                  onLeftSwipe: () => swipeLeft(),
                  onRightSwipe: () => swipeRight(),
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
                    child: Text("Reset deck", style: TextStyle(height: 1, fontSize: 40, color: Color(0xff191414),),),
                    onPressed: () {
                      setState(() => currentCardIndex = 0);
                      cards = null;
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff1DB954), // background
                      onPrimary: Color(0xff191414), // foreground
                    ),
                  ),
                ),
              Center(
                child: ElevatedButton(
                  child: Text("Play/Pause", style: TextStyle(height: 1.25, fontSize: 40, color: Color(0xff191414),),),
                  onPressed: () {
                    PAUSED ? resume():pause();
                    PAUSED = !PAUSED;
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xff1DB954), // background
                    onPrimary: Color(0xff191414), // foreground
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
    args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Sonder', style: TextStyle(height: 1, fontSize: 40, color: Color(0xff191414),),),
        backgroundColor: Color(0xff1DB954),
        automaticallyImplyLeading: true,
      ),
      body: projectWidget(args),
      backgroundColor: Color(0xff191414),
    );
  }

  void swipeLeft() {
    print("left");
    pause();
    // NOTE: it is your job to change the card
    setState(() => currentCardIndex++);
  }

  Future<void> swipeRight() async {
    print("right");
    pause();
    var res = http.post(
      'https://api.spotify.com/v1/playlists/' +
          PLAYLIST_ID +
          '/tracks?uris=spotify:track:' +
          cards[currentCardIndex].URI,
      headers: HEADERS,
    );
    setState(() => currentCardIndex++);
  }
}
