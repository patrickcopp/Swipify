import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'example_route.dart';
import 'example_slide_route.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/crossfade_state.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

void main() {
  runApp(MaterialApp(
    title: 'Named Routes Demo',
    // Start the app with the "/" named route. In this case, the app starts
    // on the FirstScreen widget.
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => FirstScreen(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/second': (context) => ExampleRouteSlide(),
    },
  ));
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Launch screen'),
          onPressed: () {
            connectToSpotifyRemote();
            //Navigator.pushNamed(context, '/second');
          },
        ),
      ),
    );
  }

  Future<void> connectToSpotifyRemote() async {
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: "ed2803e840844844b3120ab2cc82dcd5",
          redirectUrl: "http://localhost:8888/callback");
      print(result);

  }
}
