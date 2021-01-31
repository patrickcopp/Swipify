import 'dart:convert';

import 'package:flutter/material.dart';
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
        URI: recommendedList[i]["id"]));
  }
  return _cards;
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
                    onPressed: () {
                      setState(() => currentCardIndex = 0);
                      cards = null;
                    },
                  ),
                ),

              // only show the card controlling buttons when there are cards
              // otherwise, just hide it
              if (currentCardIndex < cards.length)
                cardControllerRow(_cardController),
              Center(
                child: ElevatedButton(
                  child: Text("Go To Main"),
                  onPressed: () {
                    // Navigate to the second screen using a named route.
                    Navigator.pushNamed(context, '/');
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
    args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Songs'),
      ),
      body: projectWidget(args),
    );
  }

  void swipeLeft() {
    print("left");

    // NOTE: it is your job to change the card
    setState(() => currentCardIndex++);
  }

  Future<void> swipeRight() async {
    print("right");
    setState(() => currentCardIndex++);
    var res = http.post(
      'https://api.spotify.com/v1/playlists/' +
          PLAYLIST_ID +
          '/tracks?uris=spotify:track:' +
          cards[0].URI,
      headers: HEADERS,
    );
  }

  void swipeTop() {
    print("top");
    setState(() => currentCardIndex++);
  }

  void swipeBottom() {
    print("bottom");
    setState(() => currentCardIndex++);
  }

  Widget cardControllerRow(SwipeableWidgetController cardController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        ElevatedButton(
          child: Text("Left"),
          onPressed: () => swipeLeft(),
        ),
        ElevatedButton(
          child: Text("Right"),
          onPressed: () => swipeRight(),
        ),
      ],
    );
  }
}
