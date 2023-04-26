import 'package:chat_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

late Size mq;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //Get.lazyPut(()=>DataClass)
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NTV Chat',
      theme: ThemeData(
        iconTheme: IconThemeData(color: Colors.white,size: 28),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 1,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 20),
        ),
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}