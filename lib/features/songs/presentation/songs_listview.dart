import 'dart:async';
import 'package:assignment/features/auth/presentation/authentication_provider.dart';
import 'package:assignment/features/favourite_songs/presentation/faourite_songs_provider.dart';
import 'package:assignment/features/songs/presentation/song_listview_widget.dart';
import 'package:assignment/features/songs/presentation/songs_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../configuration/theme_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/logger_helper.dart';

import '../../favourite_songs/repository/FavouriteSongsRepository.dart';
import '../data/song.dart';

class SongsListView extends StatefulWidget {
  const SongsListView({super.key});

  @override
  State<SongsListView> createState() => _SongsListViewState();
}

class _SongsListViewState extends State<SongsListView> {
  Widget likeWidget({required SongWithArtist song}) {
    AuthenticationProvider authProvider =
        Provider.of<AuthenticationProvider>(context);
    FavouriteSongsProvider myFavSongsData =
        Provider.of<FavouriteSongsProvider>(context);
    return GestureDetector(
      onTap: () {
        if (myFavSongsData.likedSongsID.contains(song.songID)) {
          myFavSongsData.removeSong(
              userID: authProvider.user!.uid, songToRemove: song);
        } else {
          myFavSongsData.addSong(userID: authProvider.user!.uid, newSong: song);
        }
        myFavSongsData.notifyListeners();
      },
      child: Icon(
        FeatherIcons.heart,
        color: myFavSongsData.isExists(songID: song.songID ?? "")
            ? Colors.redAccent
            : Colors.brown,
      ),
    );
  }

  @override
  void initState() {
    StreamSubscription<List<ConnectivityResult>> subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      LoggerHelper.showSuccessLog(text: 'connection state changed : $result');

      if (!result.contains(ConnectivityResult.none)) {
        FavouriteSongsRepository().checkUpdateFavouriteSongs();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(25), topLeft: Radius.circular(25)),
          child: Container(
            decoration: BoxDecoration(
                color:
                    themeProvider.isLightTheme() ? lightYellow : darkThemeColor,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25))),
            child: Consumer<SongsProvider>(
              builder: (context, songsProvider, _) {
                if (songsProvider.isLoading && songsProvider.songs.isEmpty) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: themeProvider.isLightTheme()
                        ? lightThemeColor
                        : darkThemeColor,
                  ));
                } else {
                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo is ScrollEndNotification &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        songsProvider.fetchSongs();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: songsProvider.songs.length +
                          (songsProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < songsProvider.songs.length) {
                          final song = songsProvider.songs[index];
                          return SongListViewWidget(song: song);
                        } else {
                          return Padding(
                            padding:  EdgeInsets.all(8.0.r),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: themeProvider.isLightTheme()
                                      ? darkThemeColor
                                      : lightYellow),
                            ),
                          );
                        }
                      },
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
