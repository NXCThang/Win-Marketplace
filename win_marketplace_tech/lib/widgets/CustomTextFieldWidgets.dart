import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/Constants.dart';

Widget customTextFieldWidget(
    int maxLines, String hintText, TextEditingController controller) {
  Constants constants = Constants();

  return Padding(
    padding: const EdgeInsets.all(3.0),
    child: TextField(
      style: TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      maxLines: maxLines,
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: constants.brandColor),
        ),
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        contentPadding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0,
            15.0),
      ),
    ),
  );
}
