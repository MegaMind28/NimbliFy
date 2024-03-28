import 'package:assignment/utils/logger_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/business/authentication.dart';

class FavouriteSongsData {
  static const _keyLikedSongsID = 'liked_songs_id_';
  static const _keyIsUpdateNecessary = 'is_update_necessary_';

  String? currentUserId = AuthenticationService().firebaseAuth.currentUser?.uid;

  Future<void> saveLikedSongs(String userID, List<String> likedSongsID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('$_keyLikedSongsID$userID', likedSongsID);
  }

  Future<List<String>> getLikedSongs(String userID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_keyLikedSongsID$userID') ?? [];
  }

  Future<void> saveUpdateNecessity(String userID, bool isUpdateNecessary) async {
    LoggerHelper.showSuccessLog(text: 'setting isUpdateNecessay flag of $userID to $isUpdateNecessary');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyIsUpdateNecessary$userID', isUpdateNecessary);
  }

  Future<bool> getUpdateNecessity(String userID) async {

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyIsUpdateNecessary$userID') ?? false;
  }

  Future<bool> removeLikedSong( {required String userID , required String songToRemove}) async {

    try{
      LoggerHelper.showSuccessLog( text: 'removing song : $songToRemove for user : $userID');
      final prefs = await SharedPreferences.getInstance();
      List<String>? likedSongs = prefs.getStringList('$_keyLikedSongsID$userID');
      if (likedSongs != null) {
        likedSongs.remove(songToRemove);
        await prefs.setStringList('$_keyLikedSongsID$userID', likedSongs);
      }
      return true;
    }catch(er){
      LoggerHelper.showErrorLog( text: 'error while removing liked song from sharedPref : $er');
      return false;
    }


  }

  Future<bool> addLikedSong({required String userID, required String newSong}) async {

    try{
      print('adding song : $newSong for user : $userID');
      final prefs = await SharedPreferences.getInstance();
      List<String>? likedSongs = prefs.getStringList('$_keyLikedSongsID$userID');
      if (likedSongs != null) {
        likedSongs.add(newSong);
      } else {
        likedSongs = [newSong];
      }
      await prefs.setStringList('$_keyLikedSongsID$userID', likedSongs);
      return true;
    }catch(err){
      LoggerHelper.showErrorLog( text: 'error while adding like song from sharedPref : $err');
      return false;
    }


  }

  Future<bool> saveAllLikedSongs({ required List<String> newSongs}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('$_keyLikedSongsID$currentUserId', newSongs);
      return true;
    } catch (err) {
      LoggerHelper.showErrorLog( text: 'error while saving all liked song in sharedPref : $err');
      return false;
    }
  }

}
