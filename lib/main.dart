import 'package:assignment/configuration/theme_provider.dart';
import 'package:assignment/features/audio_player/presentation/audio_player_provider.dart';
import 'package:assignment/features/favourite_songs/presentation/faourite_songs_provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'features/auth/business/authentication.dart';
import 'features/auth/presentation/authentication_provider.dart';
import 'features/auth/presentation/homescreen.dart';
import 'features/auth/presentation/loginScreen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/songs/presentation/songs_provider.dart';
import 'utils/firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final AuthenticationService authService = AuthenticationService();

  runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => SongsProvider()),
        ChangeNotifierProvider(create: (_) => FavouriteSongsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        Provider<AuthenticationService>.value(value: authService),
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (_) => AuthenticationProvider(authenticationService: authService),
        ),

      ],
          child:
          MyApp()

        //      DevicePreview(
        //   enabled: !kReleaseMode,
        //   builder: (context) => MyApp(), // Wrap your app
        // ),

      ));
}




class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 850.9090909090909),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context , child) {
        return Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'NimbliFy',
                theme: themeProvider.themeData,
                home: child,
              );
            }
        );
      },


      child:
      const SplashScreen()
    );


  }
}





