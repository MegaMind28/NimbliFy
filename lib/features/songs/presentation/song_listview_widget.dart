import 'package:assignment/features/songs/data/song.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../configuration/theme_provider.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/show_toast.dart';
import '../../audio_player/presentation/audio_player_provider.dart';
import '../../auth/presentation/authentication_provider.dart';
import '../../favourite_songs/presentation/faourite_songs_provider.dart';


class SongListViewWidget extends StatefulWidget {
  final SongWithArtist song;

  const SongListViewWidget({super.key, required this.song});

  @override
  _SongListViewWidgetState createState() => _SongListViewWidgetState();
}

class _SongListViewWidgetState extends State<SongListViewWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget likeWidget({required SongWithArtist song}) {
    return Consumer<ThemeProvider>(
      builder: (themeContext, themeProvider, _) {
        return Consumer<FavouriteSongsProvider>(
          builder: (favSongsContext, MyFavSongsData, _) {
            AuthenticationProvider authProvider = Provider.of<AuthenticationProvider>(favSongsContext, listen: false);
            return IconButton(onPressed: (){
              if (MyFavSongsData.likedSongsID.contains(song.songID)) {
                MyFavSongsData.removeSong(userID: authProvider.user!.uid, songToRemove: song);
              } else {
                MyFavSongsData.addSong(userID: authProvider.user!.uid, newSong: song);
              }
              MyFavSongsData.notifyListeners();
            }, icon: Icon(
              size: 25.r,
              MyFavSongsData.isExists(songID: song.songID ?? "") ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: MyFavSongsData.isExists(songID: song.songID ?? "") ?
              themeProvider.isLightTheme() ?  Colors.redAccent : Colors.redAccent
                  : themeProvider.isLightTheme() ? darkThemeColor : lightYellow,
            ),);

          },
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
   return Consumer<ThemeProvider>(
      builder: (themeContext, themeProvider, _) {
        return FadeTransition(
          opacity: _animation,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child:

            Bounceable(
              curve: Curves.bounceOut,
                duration: const Duration(milliseconds: 150),
                onTap: () async {

                bool isInternetConnected = await ConnectivityService.isConnectedToInternet();

                if(isInternetConnected){
                  Provider.of<AudioPlayerProvider>(context, listen: false).playAudio(
                    songId: widget.song.songID,
                    url: widget.song.songUrl ?? "",
                    songThumbnail: widget.song.songThumbnail,
                    artistDp: widget.song.artistDp,
                    artistName: widget.song.artistName,
                    songName: widget.song.name,
                  );
                } else {
                  showToast(
                      toastMsg: 'No Internet Found');
                }
                },
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          height: 70.r,
                          width: 70.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            color: themeProvider.currentTheme == ThemeModeType.light ? lightThemeColor : darkThemeColor,
                          ),
                          child: FadeInImage(
                            placeholder: const AssetImage('assets/images/transparent.png'), // Transparent placeholder image
                            image: NetworkImage(
                              widget.song.songThumbnail ?? "",
                            ),
                            fit: BoxFit.cover,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                       SizedBox(width: 16.w ), // Adjust spacing as needed
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.song.name ?? "Null",
                            style: customTextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.normal,
                              color: themeProvider.isLightTheme() ? darkThemeColor : lightThemeColor,
                            ),
                          ),
                           SizedBox(height: 4.h),
                          Text(
                            widget.song.artistName ?? "NULL",
                            style: customTextStyle(
                              fontSize: 15.sp,
                              color: themeProvider.isLightTheme() ? darkThemeColor : Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      likeWidget(song: widget.song),
                    ],
                  ),
                ),
            )
          ),
        );
      },
    );
  }
}