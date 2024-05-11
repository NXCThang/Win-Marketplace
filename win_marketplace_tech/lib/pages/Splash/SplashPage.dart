import 'dart:async';

import 'package:flutter/material.dart';
import 'package:win_marketplace_tech/pages/Home/HomePage.dart';

import '../../utils/Constants.dart';


class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Gọi hàm _navigateToHome() sau 4 giây
    Timer(Duration(seconds: 2), _navigateToHome);
  }

  // Hàm chuyển đến trang chính
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => HomePage()),
    );
  }

  Constants constants = Constants();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            image: DecorationImage(
                image: AssetImage("images/splash.png"),
                fit: BoxFit.cover,
                scale: 0.5)),
      ),
    );
  }
}
