import 'dart:io';
import 'package:flutter/foundation.dart';

// Platform throw error in web, so we wrap it in
//a class to avoid import errors and make it easier to
//use throughout the app without worrying about platform
//checks everywhere.
class AppPlatform {
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !isWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isDesktop =>
      !isWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  static bool get isAndroid => !isWeb && Platform.isAndroid;
  static bool get isIOS => !isWeb && Platform.isIOS;
  static bool get isWindows => !isWeb && Platform.isWindows;
  static bool get isLinux => !isWeb && Platform.isLinux;
  static bool get isMacOS => !isWeb && Platform.isMacOS;
}
