import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'song_cards_route.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/crossfade_state.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;

var CLIENT_STRING = "ed2803e840844844b3120ab2cc82dcd5";
var REDIRECT_URL = "http://localhost:8888/callback";
var USER_ID = "";
var authToken = "";
var headers;

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
      '/second': (context) => SongCardSlide(),
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
            connectToSpotifyRemote(context);
          },
        ),
      ),
    );
  }

  Future<void> connectToSpotifyRemote(BuildContext context) async {
    var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: "ed2803e840844844b3120ab2cc82dcd5",
        redirectUrl: "http://localhost:8888/callback");
    authToken = await SpotifySdk.getAuthenticationToken(
        clientId: CLIENT_STRING,
        redirectUrl: REDIRECT_URL,
        scope: 'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing, '
            'playlist-modify-public, '
            'playlist-modify-private'
    );

    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $authToken'
    };

    var res = await http.get('https://api.spotify.com/v1/me', headers: headers);
    Navigator.pushNamed(
        context,
        '/second',
      arguments: {
        'headers': headers
      },
    );


    bool playlistCreated = await makeNewPlaylist(res.body);

  }

  makeNewPlaylist(String body) async {
    var parseString = "\"uri\" : \"spotify:user:";
    if(!body.contains(parseString)) {
      return false;
    }
    var startIndex = body.indexOf(parseString) + parseString.length;
    var endIndex = body.indexOf("\"", startIndex);
    USER_ID = body.substring(startIndex,endIndex);
    var res = await http.get('https://api.spotify.com/v1/me/playlists?limit=50',
        headers: headers,
    );
    if(!res.body.contains("\"name\" : \"cuHackPlaylist\"")) {
      res = await http.post(
          'https://api.spotify.com/v1/users/' + USER_ID + '/playlists',
          headers: headers,
          body: '{"name": "cuHackPlaylist","description": "Hackerman strikes again.","public": false}'
      );
      if(res.statusCode!=201) return false;
    }
    return true;
  }

}

