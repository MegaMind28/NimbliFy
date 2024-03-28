import 'package:assignment/utils/constants.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'audio_player_provider.dart';
import '../../auth/presentation/authentication_provider.dart';
import '../../favourite_songs/presentation/faourite_songs_provider.dart';
import '../../songs/data/song.dart';

class SongDetailScreen extends StatefulWidget {
  final String imageUrl;

  const SongDetailScreen({super.key, required this.imageUrl});

  @override
  _SongDetailScreenState createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late PaletteGenerator _paletteGenerator;
  bool _isLoading = true;
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _generatePalette();
  }

  Future<void> _generatePalette() async {
    _paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.imageUrl),
      size: const Size(200, 100), // Adjust size as needed for better accuracy
    );
    setState(() {
      _dominantColor = _paletteGenerator.dominantColor!.color;
      _isLoading = false;
    });
  }

  Color lighten(Color color, double factor) {
    assert(0.0 <= factor && factor <= 1.0);
    int red = color.red + ((255 - color.red) * factor).toInt();
    int green = color.green + ((255 - color.green) * factor).toInt();
    int blue = color.blue + ((255 - color.blue) * factor).toInt();
    red = red.clamp(0, 255);
    green = green.clamp(0, 255);
    blue = blue.clamp(0, 255);
    return Color.fromARGB(color.alpha, red, green, blue);
  }

  Color getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  Widget restartSong() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, _) {
        return IconButton(
          icon: Icon(
              color: getTextColorForBackground(_dominantColor!),
              FeatherIcons.repeat),
          onPressed: () {
            audioProvider.playAgain();
          },
        );
      },
    );
  }

  Widget likeWidget({required SongWithArtist song}) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        return Consumer<FavouriteSongsProvider>(
          builder: (context, myFavSongsData, _) {
            return IconButton(
                onPressed: () {
                  if (myFavSongsData.likedSongsID.contains(song.songID)) {
                    myFavSongsData.removeSong(
                        userID: authProvider.user!.uid, songToRemove: song);
                  } else {
                    myFavSongsData.addSong(
                        userID: authProvider.user!.uid, newSong: song);
                  }
                  myFavSongsData.notifyListeners();
                },
                icon: Icon(
                  fill: 1,
                  myFavSongsData.isExists(songID: song.songID ?? "") ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  size: 25.r,
                  color: myFavSongsData.isExists(songID: song.songID ?? "")
                      ? Colors.redAccent
                      : getTextColorForBackground(_dominantColor!),
                ));
          },
        );
      },
    );
  }

  Widget _buildPlayPauseButton() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, _) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lighten(_dominantColor!, 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: IconButton(
              icon: Icon(
                size: 38.r,
                color: getTextColorForBackground(_dominantColor!),
                audioProvider.audioState == AudioState.playing
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              onPressed: () {
                if (audioProvider.audioState == AudioState.playing) {
                  audioProvider.pauseAudio();
                } else {
                  audioProvider.resumeAudio();
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator()
        : Consumer<AudioPlayerProvider>(
            builder: (context, audioProvider, _) {
              return FractionallySizedBox(
                heightFactor: 0.8,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(15)),
                  child: Container(
                    color:
                        _dominantColor,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10.h,
                          ),
                          Padding(
                            padding:  EdgeInsets.all(10.0.r),
                            child: Center(
                              child: Container(
                                width: 70.w,
                                height: 2.5.h,
                                color:
                                    getTextColorForBackground(_dominantColor!),
                              ),
                            ),
                          ),
                          Padding(
                            padding:  EdgeInsets.all(12.0.r),
                            child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                child: SizedBox(
                                  height: 350.r,
                                  width: 350.r,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(25)),
                                    child: Image.network(
                                        fit: BoxFit.cover,
                                        audioProvider.songThumnbail ?? ""),
                                  ),
                                )),
                          ),
                          Padding(
                            padding:  EdgeInsets.only(left: 10.w  , right: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                        padding:  EdgeInsets.all(15.0.r),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(25)),
                                          child: Container(
                                            height: 70.r,
                                            width: 70.r,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: FadeInImage(
                                              placeholder: const AssetImage(
                                                  'assets/images/transparent.png'),
                                              image: NetworkImage(
                                                audioProvider.artistDp ?? "",
                                              ),
                                              fit: BoxFit.cover,
                                              imageErrorBuilder:
                                                  (context, error, stackTrace) {
                                                return const SizedBox();
                                              },
                                            ),
                                          ),
                                        )),
                                    SizedBox(
                                      height: 90.h,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            audioProvider.songName ?? "",
                                            style: customTextStyle(
                                                fontSize: 20.sp,
                                                color:
                                                    getTextColorForBackground(
                                                        _dominantColor!)),
                                          ),
                                          Text(
                                            audioProvider.artistName ?? "",
                                            style: customTextStyle(
                                                fontSize: 16.sp,
                                                color:
                                                    getTextColorForBackground(
                                                        _dominantColor!)),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:  EdgeInsets.only(
                                left: 30.w, right: 30.w , top: 10.h, bottom: 10.h),
                            child: StreamBuilder(
                                stream: audioProvider.getPositionStream(),
                                builder: (context, data) {
                                  return ProgressBar(
                                    progress:
                                        data.data ?? const Duration(seconds: 0),
                                    total: audioProvider.totalDuration ??
                                        const Duration(seconds: 0),
                                    bufferedBarColor: _dominantColor,
                                    baseBarColor: lighten(_dominantColor!, 0.8),
                                    thumbColor: lighten(_dominantColor!, 0.8),
                                    timeLabelTextStyle: customTextStyle(
                                      fontSize: 18.sp,
                                        color: getTextColorForBackground(
                                            _dominantColor!)),
                                    progressBarColor:
                                        lighten(_dominantColor!, 0.3),
                                  );
                                }),
                          ),
                           SizedBox(
                            height: 10.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              restartSong(),
                              _buildPlayPauseButton(),
                              likeWidget(
                                  song: SongWithArtist(
                                      name: audioProvider.songName,
                                      artistID: "",
                                      documentID: "",
                                      artistName: audioProvider.artistName,
                                      songID: audioProvider.songId,
                                      artistDp: audioProvider.artistDp,
                                      songThumbnail:
                                          audioProvider.songThumnbail,
                                      songUrl: "",
                                      popularity: 0))
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
