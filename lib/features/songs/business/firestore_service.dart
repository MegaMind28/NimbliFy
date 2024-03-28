import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../../../utils/logger_helper.dart';
import '../data/song.dart';



class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  DocumentSnapshot? _lastDocument;
  String artistIdKey = 'artistID';

  Future<List<SongWithArtist>> fetchSongsWithArtist({int limit = 5, required List<SongWithArtist> additionalData}) async {
    final Query query = _buildQuery(limit: limit);
    final QuerySnapshot querySnapshot = await  query.get();

    return _processQuerySnapshot(querySnapshot, additionalData);
  }

  Query _buildQuery({required int limit}) {
    Query query = firestore.collection('songs').orderBy('name').limit(limit);
    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }
    return query;
  }


  Future<List<SongWithArtist>> _processQuerySnapshot(
      QuerySnapshot querySnapshot, List<SongWithArtist> additionalData) async {
    final List<SongWithArtist> songsWithArtist = [];

    for (DocumentSnapshot songDoc in querySnapshot.docs) {
      SongWithArtist? existingSong = _findExistingSong(additionalData, songDoc[artistIdKey]);

      if(existingSong==null){
        LoggerHelper.showSuccessLog( text: 'artist not found in previous data , checking in current batch..');
        existingSong = _findExistingSong(songsWithArtist, songDoc[artistIdKey]);
      }

      if (existingSong != null && existingSong.artistID == songDoc[artistIdKey]) {
        LoggerHelper.showSuccessLog( text: 'Found artist with same artistID');
        final temp = _createSongWithArtist(songDoc, null);
        temp.artistName = existingSong.artistName;
        temp.artistDp = existingSong.artistDp;
        songsWithArtist.add(temp);
      } else {
        LoggerHelper.showSuccessLog( text: 'artist with same artistID not found, calling from firestore..');
        final artistDoc = await _fetchArtistDocument(songDoc[artistIdKey]);
        songsWithArtist.add(_createSongWithArtist(songDoc, artistDoc));
      }
    }

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
    }

    return songsWithArtist;
  }

  SongWithArtist? _findExistingSong(List<SongWithArtist> songsWithArtist, String artistID) {
    return songsWithArtist.firstWhereOrNull((song) => song.artistID == artistID);
  }

  Future<DocumentSnapshot?> _fetchArtistDocument(String artistID) async {
    final QuerySnapshot artistDocs = await firestore
        .collection('artists')
        .where('artistID', isEqualTo: artistID)
        .limit(1)
        .get();
    return artistDocs.docs.isNotEmpty ? artistDocs.docs.first : null;
  }

  SongWithArtist _createSongWithArtist(DocumentSnapshot songDoc, DocumentSnapshot? artistDoc) {
    return SongWithArtist.fromFirestore(songDoc, artistDoc);
  }
}
