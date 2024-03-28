import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../auth/business/authentication.dart';
import '../data/favourite_songs_data.dart';
import 'package:assignment/utils/logger_helper.dart';

class FavouriteSongsRepository {
  String? currentUserId = AuthenticationService().firebaseAuth.currentUser?.uid;

  bool areListsEqual(List<String> list1, List<String> list2) {
    Set<String> set1 = Set.from(list1);
    Set<String> set2 = Set.from(list2);

    return set1.length == set2.length && set1.containsAll(set2);
  }

  Future<void> _pushFavouriteSongsToDb() async {
    List<String> favouriteSongsIDs =
        await FavouriteSongsData().getLikedSongs(currentUserId!);
    try {

      CollectionReference songsCollection =
          FirebaseFirestore.instance.collection('users');

      DocumentReference docRef = songsCollection.doc(currentUserId);


      DocumentSnapshot docSnapshot = await docRef.get();
      if (docSnapshot.exists) {

        await docRef.update({'favourite_songs': favouriteSongsIDs});
        if (kDebugMode) {
          LoggerHelper.showSuccessLog( text: 'Document updated successfully');
        }
      } else {

        await docRef.set({'favourite_songs': favouriteSongsIDs});
        LoggerHelper.showSuccessLog( text: 'Document created successfully');

        // setting isUpdateRequired flag to false
      }
      FavouriteSongsData().saveUpdateNecessity(currentUserId!, false);
    } catch (e) {
      print('Error updating/creating document: $e');
    }
  }

  Future<void> checkUpdateFavouriteSongs() async {


    LoggerHelper.showSuccessLog( text: 'checking if updating fav songs is pending..');

    if (currentUserId != null) {
      bool isUpdatePending =
          await FavouriteSongsData().getUpdateNecessity(currentUserId!);
      LoggerHelper.showSuccessLog(
          text: "updating required? : $isUpdatePending");
      if (isUpdatePending == true) {
        _pushFavouriteSongsToDb();
      }
    }
  }

  bool addNewSongToFirestoreDocument({required String songID}) {
    try {
      CollectionReference<Map<String, dynamic>> collection =
          FirebaseFirestore.instance.collection('users');
      String? documentId = currentUserId;
      String newItem = songID;
      collection.doc(documentId).update({
        'favourite_songs': FieldValue.arrayUnion([newItem]),
      });
      return true;
    } catch (err) {
      LoggerHelper.showErrorLog(text: 'error while adding new song to firestore document: $err');
      return false;
    }
  }

  bool removeSongFromFirestoreDocument({required String songID}) {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      FirebaseFirestore.instance.collection('users');
      String? documentId = currentUserId;

      String itemToRemove = songID;

      collection.doc(documentId).update({
        'favourite_songs': FieldValue.arrayRemove([itemToRemove]),
      });
      return true;
    } catch (err) {
      LoggerHelper.showErrorLog(
          text: 'Error while removing song from Firestore document: $err');
      return false;
    }
  }

  Future<List<String>> fetchFavoriteSongs() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.collection('users')
          .doc(currentUserId)
          .get();
      if (documentSnapshot.exists) {
        List<String>? favoriteSongs = documentSnapshot.data()?['favourite_songs']?.cast<String>();
        return favoriteSongs ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching favorite songs: $e');
      return [];
    }
  }
}
