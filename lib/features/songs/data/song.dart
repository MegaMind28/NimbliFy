import 'package:cloud_firestore/cloud_firestore.dart';


class SongWithArtist {
  late String? name;
  final String? artistID;
  final String? documentID;
  late String? artistName;
  final String? songID;
  late String? artistDp;
  final String? songThumbnail;
  final String? songUrl;
  final int? popularity;

  SongWithArtist(
      {required this.name,
      required this.artistID,
      required this.documentID,
      required this.artistName,
      required this.songID,
      required this.artistDp,
      required this.songThumbnail,
        required this.popularity,
      required this.songUrl});

  factory SongWithArtist.fromFirestore(
      DocumentSnapshot? songDoc, DocumentSnapshot? artistDoc) {
    return SongWithArtist(
        name: songDoc?['name'],
        artistID: songDoc?['artistID'],
        documentID: songDoc?.id,
        artistName: artistDoc?['artistName'],
        songID: songDoc?['songID'],
        artistDp: artistDoc?['artistDp'],
        songThumbnail: songDoc?['songThumbnail'],
        popularity: songDoc?['popularity'],
        songUrl: songDoc?['songUrl']);
  }

  @override
  String toString() {
    return 'SongWithArtist(name: $name, artistID: $artistID, documentID: $documentID, artistName: $artistName)';
  }
}
