import 'package:assignment/features/songs/presentation/searched_results_listview.dart';
import 'package:assignment/features/songs/presentation/songs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../configuration/theme_provider.dart';
import '../../../utils/constants.dart';



class SearchSongScreen extends StatefulWidget {
  const SearchSongScreen({super.key});

  @override
  State<SearchSongScreen> createState() => _SearchSongScreenState();
}

class _SearchSongScreenState extends State<SearchSongScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SongsProvider songsProvider = Provider.of<SongsProvider>(context, listen: false);
      songsProvider.setSearchedSongs(songsProvider.songs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: themeProvider.isLightTheme() ? lightYellow : Colors.black,
          body: SafeArea(
            child: Consumer<SongsProvider>(
              builder: (context, songsProvider, _) {
                return Column(
                  children: [
                    Container(
                      color: themeProvider.isLightTheme() ? lightYellow : Colors.black,
                      child: Padding(
                        padding:  EdgeInsets.all(8.0.r),
                        child: TextField(
                          controller: searchController,
                          style: customTextStyle(
                            fontSize: 20.sp,
                            color: themeProvider.isLightTheme() ? darkThemeColor : lightThemeColor,
                          ),
                          onChanged: (String text){
                            songsProvider
                                .searchSongsLocally(searchedInput: text);
                          },
                          decoration: InputDecoration(
                            hintText: "Search Songs",
                            fillColor: themeProvider.isLightTheme() ? lightThemeColor : darkThemeColor,
                            filled: true,
                            hintStyle: customTextStyle(
                              fontSize: 20.sp,
                              color: themeProvider.isLightTheme() ? darkThemeColor : lightThemeColor
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(25)),
                            ),
                            suffixIcon: SizedBox(
                              width: 30.w ,
                              child: Row(
                                children: [

                                  IconButton(
                                      onPressed: (){
                                        searchController.clear();
                                        songsProvider.setSearchedSongs(songsProvider.songs);
                                      },
                                      icon:  Icon(
                                        size: 25.r,
                                        FeatherIcons.x,
                                        color: themeProvider.isLightTheme() ? darkThemeColor : lightThemeColor
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SearchResultsListView()



                  ],
                );

              },
            ),
          ),
        );
      },
    );
  }
}





