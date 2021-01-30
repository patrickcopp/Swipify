import 'package:flutter/material.dart';
import 'package:swipeable_card/swipeable_card.dart';
import 'package:http/http.dart' as http;

import 'song_card.dart';

class SongCardSlide extends StatefulWidget {
  const SongCardSlide({Key key}) : super(key: key);

  @override
  _SongCardRouteState createState() => _SongCardRouteState();
}

List<SongCard> cards;

Future<List<SongCard>> initCards(args) async {
  List<SongCard> cards = new List<SongCard>();
  var res = await http.get('https://api.spotify.com/v1/tracks/60Ctoy2M8nmDaI7Fax3fTL', headers: args['headers']);
  print(res.body);
  for (int i = 0; i < 5; i++) {
    cards.add(SongCard(color: Colors.deepPurpleAccent, trackTitle: "$i card"));
  }
  return cards;
}

class _SongCardRouteState extends State<SongCardSlide> {
  int currentCardIndex = 0;
  SwipeableWidgetController _cardController = SwipeableWidgetController();
  Widget projectWidget(args) {
    return FutureBuilder(
      builder: (context, cardsSnapshot) {
        if (cardsSnapshot.connectionState == ConnectionState.none &&
            cardsSnapshot.hasData == null) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Container();
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
    var args = ModalRoute.of(context).settings.arguments;
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

  void swipeRight() {
    print("right");
    setState(() => currentCardIndex++);
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
