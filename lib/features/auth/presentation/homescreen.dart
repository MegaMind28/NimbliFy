import 'package:animations/animations.dart';
import 'package:assignment/features/audio_player/presentation/audio_player_provider.dart';
import 'package:assignment/features/favourite_songs/presentation/faourite_songs_provider.dart';
import 'package:assignment/features/songs/presentation/search_song_screen.dart';
import 'package:assignment/utils/constants.dart';
import 'package:assignment/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../configuration/theme_provider.dart';
import '../../../utils/connectivity_service.dart';
import '../../audio_player/presentation/floating_audio_widget.dart';
import '../../favourite_songs/data/favourite_songs_data.dart';
import '../../favourite_songs/repository/FavouriteSongsRepository.dart';
import '../../songs/presentation/songs_listview.dart';
import '../../songs/presentation/songs_provider.dart';
import '../business/authentication.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnectedToInternet = false;

  late SongsProvider _songsProvider;
  late FavouriteSongsProvider _favouriteSongsProvider;

  void updateFavSongsToFirestore() {
    //update favourite songs if its pending/ device was offline while editing fav songs
    FavouriteSongsRepository().checkUpdateFavouriteSongs();
  }

  Future<void> updateFavSongsToLocalDb() async {
    List<String> favSongs =
        await FavouriteSongsRepository().fetchFavoriteSongs();
    bool pullSongsFromDB = FavouriteSongsRepository()
        .areListsEqual(favSongs, _favouriteSongsProvider.likedSongsID);
    LoggerHelper.showSuccessLog(text: 'onlineSongs : $favSongs');
    LoggerHelper.showSuccessLog(
        text: 'offlineSongs : ${_favouriteSongsProvider.likedSongsID}');
    LoggerHelper.showSuccessLog(text: 'pullSongsFromDB : $pullSongsFromDB');
    bool pullSongsFromDb =
        await FavouriteSongsData().saveAllLikedSongs(newSongs: favSongs);
    LoggerHelper.showSuccessLog(text: 'is local db updated : $pullSongsFromDb');
    _favouriteSongsProvider.likedSongsID = favSongs;
    _favouriteSongsProvider.notifyListeners();
  }

  Future<void> loadDataFromInternet() async {
    String? currentUserId =
        AuthenticationService().firebaseAuth.currentUser?.uid;
    _songsProvider = Provider.of<SongsProvider>(context, listen: false);
    _favouriteSongsProvider =
        Provider.of<FavouriteSongsProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      _songsProvider.fetchSongs();
      _favouriteSongsProvider.fetchLikedSongs(currentUserId!);
    });
    updateFavSongsToFirestore();
    updateFavSongsToLocalDb();
  }

  Future<void> checkInternet() async {
    isConnectedToInternet = await ConnectivityService.isConnectedToInternet();
    setState(() {
      isConnectedToInternet;
    });
    LoggerHelper.showSuccessLog(
        text: 'checking if connected to internet : $isConnectedToInternet');
    if (isConnectedToInternet == true) {
      loadDataFromInternet();
    }
  }

  @override
  void dispose() {
    Provider.of<AudioPlayerProvider>(context, listen: false).pauseAudio();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    checkInternet();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor:
              themeProvider.isLightTheme() ? lightThemeColor : Colors.black,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [

                          OpenContainer(
                            closedColor: Colors.transparent,
                            openElevation: 0,
                            tappable: false,
                            closedElevation: 0,
                            transitionType: ContainerTransitionType.fade,
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            closedBuilder: (context, action) {
                              return IconButton(
                                icon: Icon(
                                  size: 25.r,
                                  FeatherIcons.search,
                                  color: themeProvider.isLightTheme()
                                      ? darkThemeColor
                                      : lightThemeColor,
                                ),
                                onPressed: action,
                              );
                            },
                            openBuilder: (context, action) {
                              return const SearchSongScreen();
                            },
                          ),

                          customSizedBox(width: 5),

                          GestureDetector(
                            onTap: () {
                              themeProvider.toggleTheme();
                            },
                            child: Center(
                              child: Text(
                                'NimbliFy',
                                style: customTextStyle(
                                    fontSize: 20.sp,
                                    color: !themeProvider.isLightTheme()
                                        ? lightThemeColor
                                        : darkThemeColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                themeProvider.toggleTheme();
                              },
                              icon: Icon(
                                size: 25.r,
                                  color: themeProvider.isLightTheme()
                                      ? darkThemeColor
                                      : lightThemeColor,
                                  themeProvider.isLightTheme()
                                      ? FeatherIcons.sun
                                      : FeatherIcons.moon)),
                          IconButton(
                              onPressed: () {
                                Provider.of<AudioPlayerProvider>(context,
                                        listen: false)
                                    .pauseAudio();
                                AuthenticationService().signOut();
                              },
                              icon: Icon(
                                size: 25.r,
                                  color: themeProvider.isLightTheme()
                                      ? darkThemeColor
                                      : lightThemeColor,
                                  FeatherIcons.logOut))
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: isConnectedToInternet
                        ? const SongsListView()
                        : Container(
                            decoration: BoxDecoration(
                                color: themeProvider.isLightTheme()
                                    ? lightYellow
                                    : darkThemeColor,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Woops!',
                                  style: customTextStyle(
                                    fontSize: 19.sp,
                                    color: themeProvider.isLightTheme()
                                        ? darkThemeColor
                                        : lightYellow,
                                  ),
                                ),
                                Text(
                                  'No internet found :/',
                                  style: customTextStyle(
                                    fontSize: 22.sp,
                                    color: themeProvider.isLightTheme()
                                        ? darkThemeColor
                                        : lightYellow,
                                  ),
                                ),
                                Image.asset('assets/images/no_internet.png'),
                                customSizedBox(height: 30.h),
                                Bounceable(
                                  curve: Curves.bounceOut,
                                  duration: const Duration(milliseconds: 150),
                                  onTap: () async {
                                    checkInternet();
                                  },
                                  child: Padding(
                                    padding:  EdgeInsets.all(12.0.r),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: themeProvider.isLightTheme()
                                                ? darkThemeColor
                                                : lightThemeColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.black)),
                                        width: double.maxFinite,
                                        child: Padding(
                                          padding:  EdgeInsets.all(16.0.r),
                                          child: Center(
                                              child: Text(
                                            'Retry..',
                                            style: customTextStyle(
                                              fontSize: 20.sp,
                                                color:
                                                    themeProvider.isLightTheme()
                                                        ? lightYellow
                                                        : darkThemeColor),
                                          )),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          )),
                const FloatingAudioWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}

