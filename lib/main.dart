import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'song_cards_route.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;

var CLIENT_STRING = "ed2803e840844844b3120ab2cc82dcd5";
var REDIRECT_URL = "http://localhost:8888/callback";
var USER_ID = "";
var authToken = "";
var headers;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Than we setup preferred orientations,
  // and only after it finished we run our app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp((MaterialApp(
    title: 'Swipify',
    theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xff191414),
    ),
    // Start the app with the "/" named route. In this case, the app starts
    // on the FirstScreen widget.
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => FirstScreen(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/second': (context) => SongCardSlide(),
    },
  ))));
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: //Text('Swipify', style: GoogleFonts.lato(TextStyle(height: 1, fontSize: 40, color: Color(0xff191414))),),
        Text(
          'Swipify', style: TextStyle(color: Color(0xff191414), fontSize: 40, fontFamily: "Gotham", letterSpacing: -1.5),
        ),
        backgroundColor: Color(0xff1DB954),
      ),
      body: Column(
        children: <Widget>[
        new Padding(padding: EdgeInsets.only(top: 300),),
          new Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width),),
        GestureDetector(
            onTap: () => connectToSpotifyRemote(context),
            child: Image.asset('assets/loginbutton.png'),
        )
      ],

      ),
      backgroundColor: Color(0xff191414),
    );
  }

  Future<void> connectToSpotifyRemote(BuildContext context) async {
    try {
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
              'user-top-read, '
              'playlist-modify-private');

      headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken'
      };

      var res = await http.get(
          'https://api.spotify.com/v1/me', headers: headers);
      var playlistCreated = await makeNewPlaylist(res.body);

      Navigator.pushNamed(
        context,
        '/second',
        arguments: {'headers': headers, 'playlistID': playlistCreated},
      );
    }
    on Exception catch (err) {
      await showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text('Spotify Needed!', style: TextStyle(color: Color(0xff191414), fontSize: 40, fontFamily: "Gotham", letterSpacing: -1.5)),
          backgroundColor: Color(0xff1DB954),
          content: Text('Download Spotify to Continue.', style: TextStyle(color: Color(0xff191414), fontSize: 15, fontFamily: "Gotham", letterSpacing: -1.5)),
          actions: <Widget>[
            new FlatButton(
              color: Color(0xff191414),
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(); // dismisses only the dialog and returns nothing
              },
              child: new Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  makeNewPlaylist(String body) async {
    var parseString = "\"uri\" : \"spotify:user:";
    if (!body.contains(parseString)) {
      return false;
    }
    var startIndex = body.indexOf(parseString) + parseString.length;
    var endIndex = body.indexOf("\"", startIndex);
    USER_ID = body.substring(startIndex, endIndex);
    var res = await http.get(
      'https://api.spotify.com/v1/me/playlists?limit=50',
      headers: headers,
    );
    if (!res.body.contains("\"name\" : \"Swipify\"")) {
      res = await http.post(
          'https://api.spotify.com/v1/users/' + USER_ID + '/playlists',
          headers: headers,
          body:
              '{"name": "Swipify","description": "Right swiping has never been so musical.","public": false}');
      if (res.statusCode != 201) return false;
      return jsonDecode(res.body)["id"];
    } else {
      return jsonDecode(res.body)["items"].firstWhere((entry) {
        return entry["name"] == "Swipify";
      })["id"];
    }
  }
}
