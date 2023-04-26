import 'dart:developer';
import 'dart:io';
import 'package:chat_app/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../splash_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleButtonClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser:${user.user}');
        log('\nUserAdditionalInfo:${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => SplashScreen()));
        } else {
          await APIs.createUser().then((value) => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen(user: APIs.me,))));
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle : $e');
      Dialogs.showSnackBar(context, 'Lỗi , kiểm tra lại kết nối Internet');
      return null;
    }
  }

  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('NTV Chat'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                top: mq.height * 0.15,
                right: _isAnimate ? mq.width * 0.25 : -mq.width * 0.5,
                width: mq.width * 0.5,
                child: Image.asset('images/cat.png')),
            Positioned(
              height: mq.height * 0.07,
              bottom: mq.height * 0.15,
              left: mq.width * 0.05,
              width: mq.width * 0.9,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: StadiumBorder(),
                    elevation: 1),
                onPressed: () {
                  _handleGoogleButtonClick();
                },
                icon: Image.asset(
                  'images/google.png',
                  height: mq.height * 0.06,
                ),
                label: RichText(
                  text: TextSpan(style: TextStyle(fontSize: 18), children: [
                    TextSpan(text: 'Đăng nhập với '),
                    TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
