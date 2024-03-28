import 'package:flutter/material.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/logger_helper.dart';
import '../business/firestore_service.dart';
import '../data/song.dart';

class SongsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<SongWithArtist> _songs = [];
  bool _isLoading = false;

  List<SongWithArtist> _searchedSongs = [];

  List<SongWithArtist> get songs => _songs;

  List<SongWithArtist> get searchedSongs => _searchedSongs;

  bool get isLoading => _isLoading;

  void setSearchedSongs(List<SongWithArtist> songs) {
    _searchedSongs = songs;
    notifyListeners();
  }

  String? _searchedString;

  String? get searchedString => _searchedString;

  set searchedString(String? newValue) {
    _searchedString = newValue;
    notifyListeners();
  }

  List<SongWithArtist> removeDuplicateSongs(List<SongWithArtist> songs) {
    Set<String> uniqueSongIDs = {};
    List<SongWithArtist> uniqueSongs = [];

    for (var song in songs) {
      if (!uniqueSongIDs.contains(song.songID)) {
        uniqueSongs.add(song);
        uniqueSongIDs.add(song.songID ?? "");
      }
    }

    return uniqueSongs;
  }

  Future<void> fetchSongs({
    int limit = 5,
  }) async {
    bool isInternetConnected =
        await ConnectivityService.isConnectedToInternet();
    if (isInternetConnected) {
      LoggerHelper.showSuccessLog(text: 'calling songs');
      _isLoading = true;
      notifyListeners();

      final newSongs = await _firestoreService.fetchSongsWithArtist(
        limit: limit,
        additionalData: _songs,
      );

      _songs.addAll(newSongs);

      _isLoading = false;
      _songs = removeDuplicateSongs(_songs);
      notifyListeners();
      LoggerHelper.showSuccessLog(text: 'songs length : ${songs.length}');
    }
  }

  Future<void> searchSongsLocally({required String searchedInput}) async {
    String searchTerm = searchedInput;
    searchedString = searchedInput;
    notifyListeners();
    searchTerm = searchTerm.toLowerCase();

    _searchedSongs = _songs.where((SongWithArtist song) {
      String songName = song.name?.toLowerCase() ?? '';
      String artistName = song.artistName?.toLowerCase() ?? '';

      return songName.contains(searchTerm) || artistName.contains(searchTerm);
    }).toList();

    _searchedSongs.sort((a, b) => b.popularity!.compareTo(a.popularity!));

    LoggerHelper.showSuccessLog(
        text: "Searched results for $searchTerm : $_searchedSongs");
    notifyListeners();
  }

  void clearSearchedSongsLocally() {
    _searchedSongs.clear();
    notifyListeners();
  }
}
