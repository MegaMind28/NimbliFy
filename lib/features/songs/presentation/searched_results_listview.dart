import 'package:assignment/features/songs/presentation/song_listview_widget.dart';
import 'package:assignment/features/songs/presentation/songs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../configuration/theme_provider.dart';
import '../../../utils/constants.dart';

class SearchResultsListView extends StatefulWidget {
  const SearchResultsListView({super.key});

  @override
  State<SearchResultsListView> createState() => _SearchResultsListViewState();
}

class _SearchResultsListViewState extends State<SearchResultsListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Consumer<SongsProvider>(
          builder: (context, songsProvider, _) {
            return Expanded(
              child: Padding(
                padding:  EdgeInsets.all(8.0.r),
                child: Container(
                  decoration: BoxDecoration(
                      color: themeProvider.isLightTheme() ? lightThemeColor : darkThemeColor,
                      borderRadius: const BorderRadius.all(Radius.circular(25))
                  ),

                  child: songsProvider.searchedSongs.isNotEmpty ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: songsProvider.searchedSongs.length + (songsProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      final song = songsProvider.searchedSongs[index];
                      return SongListViewWidget(song: song);
                    },
                  ) :
                  Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isLightTheme() ? lightThemeColor : darkThemeColor,
                        borderRadius: const BorderRadius.all(Radius.circular(25))
                      ),
                      width: double.maxFinite,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/no_results.png'),
                          Text('Woops!',style: customTextStyle(
                            fontSize: 20.sp,
                            color: themeProvider.isLightTheme() ? darkThemeColor : lightYellow
                          ),),
                          Text('No songs found for "${songsProvider.searchedString}"',
                            style: customTextStyle(
                                fontSize: 25.sp,
                                color: themeProvider.isLightTheme() ? darkThemeColor : lightYellow
                            ),)
                        ],
                      )),
                ),
              ),
            );

          },
        );
      },
    );
  }
}
