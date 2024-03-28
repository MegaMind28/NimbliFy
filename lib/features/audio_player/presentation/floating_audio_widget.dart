import 'package:assignment/features/audio_player/presentation/song_detail_screen.dart';
import 'package:assignment/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'audio_player_provider.dart';

class FloatingAudioWidget extends StatefulWidget {
  const FloatingAudioWidget({super.key});

  @override
  _FloatingAudioWidgetState createState() => _FloatingAudioWidgetState();
}

class _FloatingAudioWidgetState extends State<FloatingAudioWidget> {



  Color getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  void dispose() {
    AudioPlayerProvider().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<AudioPlayerProvider>(
        builder: (context, audioProvider, _) {

          return audioProvider.audioState == AudioState.playing ||
              audioProvider.audioState == AudioState.paused ||
              audioProvider.audioState == AudioState.stopped
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _showImageColorModal(
                      context, audioProvider.songThumnbail ?? "");
                },
                child: Container(
                  color: audioProvider.bgColor,
                  width: MediaQuery.of(context).size.width,

                  child: Column(
                    children: [
                      _buildPositionIndicator(),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    height: 50.r,
                                    width: 50.r,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: FadeInImage(
                                      placeholder: const AssetImage('assets/images/transparent.png'), // Transparent placeholder image
                                      image: NetworkImage(
                                        audioProvider.songThumnbail ?? "",
                                      ),
                                      fit: BoxFit.cover,
                                      imageErrorBuilder: (context, error, stackTrace) {
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(audioProvider.songName ?? "",
                                    style: customTextStyle(
                                      fontSize: 17.sp,
                                      color: getTextColorForBackground(audioProvider.bgColor!)
                                    ),),
                                  Text(
                                      audioProvider.artistName ?? "",
                                      style: customTextStyle(
                                        fontSize: 15.sp,
                                          color: getTextColorForBackground(audioProvider.bgColor!).withOpacity(0.8)
                                      ))
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              playPauseButtonWidget(),
                              muteButtonWidget()
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
              : customSizedBox();
        },
      ),
    );
  }

  Widget _buildPositionIndicator() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, _) {
        bool isSongLoaded = audioProvider.audioState == AudioState.playing ||
            audioProvider.audioState == AudioState.paused;
        return Visibility(
          visible: isSongLoaded,
          child: LinearProgressIndicator(
            minHeight: 3,
            backgroundColor: Colors.grey.withOpacity(0.5),
            value: audioProvider.totalDuration != null
                ? (audioProvider.position.inMilliseconds /
                audioProvider.totalDuration!.inMilliseconds)
                : 0,
            valueColor: AlwaysStoppedAnimation<Color>(getTextColorForBackground(audioProvider.bgColor!)),
          ),
        );
      },
    );
  }

  Widget muteButtonWidget() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, _) {
        double currentVolume = audioProvider.getVolume();
        bool isMutted = currentVolume == 0.0 ? true : false;
        return IconButton(

          color: getTextColorForBackground(audioProvider.bgColor!),
          icon: Icon(
            size: 25.r,
            isMutted == true ? Icons.volume_off : Icons.volume_up,
          ),
          onPressed: () {
            if (isMutted) {
              audioProvider.changeVolume(1.0);
            } else {
              audioProvider.changeVolume(0.0);
            }
          },
        );
      },
    );
  }

  Widget playPauseButtonWidget() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, _) {
        return IconButton(
          icon: Icon(
            size: 25.r,
            color: getTextColorForBackground(audioProvider.bgColor!),
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
        );
      },
    );
  }

  void _showImageColorModal(BuildContext context, String imgUrl) {
    showMaterialModalBottomSheet(
      bounce: true,
      barrierColor: Colors.black.withOpacity(0.4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (context) => Builder(
        builder: (BuildContext context) => SongDetailScreen(
          imageUrl: imgUrl,
        ),
      ),
    );
  }
}
