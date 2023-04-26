import 'dart:developer';

import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/main.dart';
import 'package:flutter/services.dart';

import '../api/apis.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //if(APIs.auth.currentUser!=null) APIs.getMyInfo();

    Future.delayed(const Duration(milliseconds: 3000), ()  {
      setState(() async {
        //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
        if(APIs.auth.currentUser!=null) {
           await APIs.getMyInfo();
          log('\nUser:${APIs.auth.currentUser}');
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen(user: APIs.me,)));
        }
        else Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
      });
    });
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
            Positioned(
                top: mq.height * 0.15,
                right: mq.width * 0.25,
                width: mq.width * 0.5,
                child: Image.asset('images/cat.png')),
            Positioned(
                bottom: mq.height * 0.15,
                width: mq.width,
                child: Text(
                  'NguyenTheVan 2023 💚',
                  style: TextStyle(color: Colors.white, fontSize: 16,letterSpacing: 0.5),
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),
    );
  }
}
