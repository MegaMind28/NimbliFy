import 'package:assignment/utils/constants.dart';
import 'package:assignment/utils/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../configuration/theme_provider.dart';
import '../../../utils/connectivity_service.dart';
import '../business/authentication.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required AuthenticationService authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late  AuthenticationService authService;
  bool _isObscure = true;

  @override
  void initState() {
    authService = AuthenticationService();
    super.initState();
    emailController.text = 'siddhesh.parab28@gmail.com';
    passwordController.text = '12345678';
  }

  @override
  Widget build(BuildContext context) {
    return  Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: themeProvider.isLightTheme() ? lightYellow : darkThemeColor,
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/music.png'),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(25)),
                              child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Image.asset('assets/images/logo.png')),
                            ),
                              customSizedBox(width: 20),
                              Text('NimbliFy',style: customTextStyle(
                                fontSize: 25.sp,
                                color: themeProvider.isLightTheme() ? darkThemeColor : lightYellow
                              ),)

                            ],
                          ),
                        ),

                        Text("Get ready to dive into the rhythm!",
                        style: customTextStyle(
                          fontSize: 20.sp,
                          color: themeProvider.isLightTheme() ? darkThemeColor : lightYellow
                        ),),

                        customSizedBox(height: 10.h),

                        TextField(
                          controller: emailController,
                          style: customTextStyle(
                            fontSize: 20.sp,
                            color: themeProvider.isLightTheme() ? darkThemeColor : lightThemeColor,
                          ),
                          decoration: InputDecoration(
                            hintText: "Email",
                            fillColor: themeProvider.isLightTheme() ? lightThemeColor : lightYellow.withOpacity(0.1),
                            filled: true,
                            hintStyle: customTextStyle(
                              fontSize: 20.sp,
                              color: themeProvider.isLightTheme() ? darkThemeColor : lightThemeColor,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                        customSizedBox(height: 10.h),
                        TextField(
                          controller: passwordController,
                          obscureText: _isObscure,
                          style: customTextStyle(
                            fontSize: 20.sp,
                            color: themeProvider.isLightTheme() ? darkThemeColor : lightThemeColor,
                          ),
                          decoration: InputDecoration(
                            hintText: "Password",
                            fillColor: themeProvider.isLightTheme() ? lightThemeColor : lightYellow.withOpacity(0.1),
                            filled: true,
                            hintStyle: customTextStyle(
                              fontSize: 20.sp,
                              color: themeProvider.isLightTheme() ? darkThemeColor : lightThemeColor,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                              child: Icon(
                                _isObscure ? Icons.visibility : Icons.visibility_off, // Show appropriate icon
                                color: themeProvider.isLightTheme() ? darkThemeColor : lightThemeColor,
                              ),
                            ),
                          ),
                        ),
                        customSizedBox(height: 10.h),
                        GestureDetector(
                          onTap: () async {

                            bool isInternetConnected = await ConnectivityService.isConnectedToInternet();

                            if(isInternetConnected){
                              String? error = await authService.signIn
                                (email: emailController.text, password: passwordController.text);
                            } else {
                              showToast(toastMsg: 'No Internet Found!');
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeProvider.isLightTheme() ? darkThemeColor : lightThemeColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.black
                              )
                            ),
                              width: double.maxFinite,
                              child: Padding(
                                padding:  EdgeInsets.all(16.0.r),
                                child: Center(child: Text('Sign In to Start Music Journey!',
                                style: customTextStyle(
                                  fontSize: 18.sp,
                                  color: themeProvider.isLightTheme()? lightYellow : darkThemeColor
                                ),
                                )),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


