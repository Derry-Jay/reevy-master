import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';

class AuthStatus {
  static bool isAnonymous = false;
  static String currentUserId;
  static String currentUserNickname;

}

class AppColors{
  static Color salmon = Color.fromARGB(0xFF, 0xFF, 0x63, 0x55);
  static Color lessSalmon = Color.fromARGB(0x50, 0xFF, 0x63, 0x55);
  static Color cleanGrey = Color.fromARGB(0xFF, 0xEA, 0xF1, 0xF8);
  static Color commentGrey = Color.fromARGB(0xFF, 0xDE, 0xE5, 0xEB);
}