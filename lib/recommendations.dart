import 'dart:convert';

import 'package:http/http.dart' as http;
import "dart:math";

Future<List<dynamic>> getRecommendedTracks(headers) async {
  if(headers == null)
    return null;
  var getTopSongs = await http.get(
      'https://api.spotify.com/v1/me/top/tracks?limit=10',
      headers: headers);
  var topSongs = jsonDecode(getTopSongs.body);
  var random = new Random();
  var seedTracks =
      topSongs["items"][random.nextInt(topSongs["items"].length)]["id"];

  var getTopArtists = await http.get(
      'https://api.spotify.com/v1/me/top/artists?time_range=medium_term&limit=10',
      headers: headers);

  var topArtists = jsonDecode(getTopArtists.body);

  var seedArtists =
      topArtists["items"][random.nextInt(topSongs["items"].length)]["id"];

  var genreString = "";

  for (var i = 0; i < 3; i++) {
    var genreArray =
        topArtists["items"][random.nextInt(topSongs["items"].length)]["genres"];
    if (genreArray.length > 0) {
      var genreIndex = random.nextInt(genreArray.length);
      genreString = genreString + genreArray[genreIndex];
      if (i != 2) {
        genreString = genreString + ",";
      }
    }
  }

  var getRecommendations = await http.get(
      'https://api.spotify.com/v1/recommendations?limit=25&seed_artists=$seedArtists&seed_genres=$genreString&seed_tracks=$seedTracks',
      headers: headers);

  var results = jsonDecode(getRecommendations.body);

  return results["tracks"];
}
