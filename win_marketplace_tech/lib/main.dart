import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:win_marketplace_tech/pages/Home/HomePage.dart';
import 'package:win_marketplace_tech/services/ContractFactoryServies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
  ? await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyDDVAUyhkFk1Ezjky9Ev7o2496pZu3jt9s',
        appId: '1:540644359099:android:2006429227c58f9702a29e',
        messagingSenderId: '540644359099',
        projectId: 'win-flutter'
    ))
      : await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContractFactoryServies>(
      create: (context) => ContractFactoryServies(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}