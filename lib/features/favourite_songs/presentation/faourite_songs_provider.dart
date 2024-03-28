import 'package:assignment/features/favourite_songs/data/favourite_songs_data.dart';
import 'package:assignment/features/songs/data/song.dart';
import 'package:assignment/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/show_toast.dart';
import '../repository/FavouriteSongsRepository.dart';

class FavouriteSongsProvider with ChangeNotifier {

  List<String> _likedSongsID = [];
  bool _isUpdateNeeded = false;

  List<String> get likedSongsID => _likedSongsID;
  bool get isUpdateNeeded => _isUpdateNeeded;

  set likedSongsID(List<String> newValue) {
    _likedSongsID = newValue;
    notifyListeners();
  }

  Future<void> saveLikedSongs(
      {required String userID, required List<String> likedSongsID}) async {
    await FavouriteSongsData().saveLikedSongs(userID, likedSongsID);
    _likedSongsID = likedSongsID;
    notifyListeners();
  }

  Future<void> fetchLikedSongs(String userID) async {
    LoggerHelper.showSuccessLog(text: "userID WHILE FETCHING LOCAL SONGS: $userID");
    LoggerHelper.showSuccessLog( text: 'getting local songs ID');
    _likedSongsID = await FavouriteSongsData().getLikedSongs(userID);
    print(_likedSongsID);
    notifyListeners();
  }

  Future<void> saveUpdateNecessity({required String userID, required bool isUpdateNeeded}) async {
    LoggerHelper.showSuccessLog( text: 'updating boool');
    await FavouriteSongsData().saveUpdateNecessity(userID, isUpdateNeeded);
    _isUpdateNeeded = isUpdateNeeded;
    notifyListeners();
    fetchUpdateNecessity(userID);
  }

  Future<void> fetchUpdateNecessity(String userID) async {
    _isUpdateNeeded = await FavouriteSongsData().getUpdateNecessity(userID);
    LoggerHelper.showSuccessLog( text: 'new bool : $_isUpdateNeeded');
    notifyListeners();
  }

  Future<void> removeSong({required String userID, required SongWithArtist songToRemove}) async {
    bool isRemoved = await FavouriteSongsData().removeLikedSong(userID : userID , songToRemove : songToRemove.songID??"");
    bool isConnectedToInternet = await ConnectivityService.isConnectedToInternet();
    LoggerHelper.showSuccessLog(text: 'internet status : $isConnectedToInternet');
    if(isConnectedToInternet==true){
      bool pushedToDb = await  FavouriteSongsRepository().removeSongFromFirestoreDocument(songID: songToRemove.songID??"");
      if(pushedToDb==false){
        FavouriteSongsData().saveUpdateNecessity(userID, true);
      }
    }else {
      FavouriteSongsData().saveUpdateNecessity(userID, true);
    }

    if(isRemoved){
      _likedSongsID.remove(songToRemove.songID);
      showToast(
          toastMsg: 'Disliked ${songToRemove.name}');
      LoggerHelper.showSuccessLog(text: 'disliked song : ${songToRemove.name}');
      notifyListeners();
    }

  }

  Future<void> addSong({required String userID, required SongWithArtist newSong}) async {

    bool isAdded = await FavouriteSongsData().addLikedSong(userID : userID , newSong : newSong.songID??"");
    bool isConnectedToInternet = await ConnectivityService.isConnectedToInternet();
    LoggerHelper.showSuccessLog(text: 'internet status : $isConnectedToInternet');
    if(isConnectedToInternet==true){
      bool pushedToDb = await  FavouriteSongsRepository().addNewSongToFirestoreDocument(songID: newSong.songID??"");
      if(pushedToDb==false){
        FavouriteSongsData().saveUpdateNecessity(userID, true);
      }
    }else {
      FavouriteSongsData().saveUpdateNecessity(userID, true);
    }
    if(isAdded){
      _likedSongsID.add(newSong.songID??"");
      showToast(
          toastMsg: 'Liked ${newSong.name}');
      LoggerHelper.showSuccessLog( text: 'liked new song : ${newSong.name}',);
      notifyListeners();
    }

  }

  bool isExists({required String songID}) {
    bool isLiked = _likedSongsID.contains(songID);
    return isLiked;
  }
}
