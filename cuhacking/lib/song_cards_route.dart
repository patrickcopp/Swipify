import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
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

var PLAYLIST_ID = "";
var HEADERS;
List<SongCard> cards = null;
var args;
String currentSong;
int currentCardIndex = 0;

Future<List<SongCard>> initCards(args) async {
  if (currentCardIndex > 20) {
    while (cards.length != 4) {
      cards.removeAt(0);
    }
    currentCardIndex = 0;

    var recommendedList = await getRecommendedTracks(HEADERS);

    for (int i = 0; i < recommendedList.length - 4; i++) {
      cards.add(SongCard(
          color: Colors.white70.withOpacity(1),
          trackTitle: recommendedList[i]["name"],
          imageUrl: recommendedList[i]["album"]["images"][0]["url"],
          URI: recommendedList[i]["id"]));
    }
  }
  if (cards != null) {
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

class _SongCardRouteState extends State<SongCardSlide> {
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
        title: Text(
          'Swipify', style: GoogleFonts.oswald(textStyle: TextStyle(color: Color(0xff191414), letterSpacing: .5, fontSize: 40),),
        ),
        backgroundColor: Color(0xff1DB954),
        automaticallyImplyLeading: true,
      ),
      body: projectWidget(args),
      backgroundColor: Color(0xff191414),
    );
  }

  void swipeLeft() {
    print("left");
    // NOTE: it is your job to change the card
    setState(() => currentCardIndex++);
  }

  Future<void> swipeRight() async {
    print("right");
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
