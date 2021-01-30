import 'package:flutter/material.dart';
import 'package:swipeable_card/swipeable_card.dart';

import 'song_card.dart';

class ExampleRouteSlide extends StatefulWidget {
  const ExampleRouteSlide({Key key}) : super(key: key);

  @override
  _ExampleRouteSlideState createState() => _ExampleRouteSlideState();
}

List<SongCard> init() {
  List<SongCard> cards = new List<SongCard>();
  for (int i = 0; i < 5; i++) {
    cards.add(SongCard(color: Colors.deepPurpleAccent, trackTitle: "$i card"));
  }
  return cards;
}

class _ExampleRouteSlideState extends State<ExampleRouteSlide> {
  final List<SongCard> cards = init();
  int currentCardIndex = 0;

  @override
  Widget build(BuildContext context) {
    SwipeableWidgetController _cardController = SwipeableWidgetController();
    return Scaffold(
      body: SafeArea(
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
      ),
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
