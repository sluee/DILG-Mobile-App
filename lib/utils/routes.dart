import 'package:DILGDOCS/screens/about_screen.dart';
import 'package:DILGDOCS/screens/change_password_modal.dart';
import 'package:DILGDOCS/screens/edit_user.dart';
import 'package:DILGDOCS/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import '../screens/draft_issuances.dart';
import '../screens/joint_circulars.dart';
import '../screens/latest_issuances.dart';
import '../screens/legal_opinions.dart';
import '../screens/memo_circulars.dart';
import '../screens/presidential_directives.dart';
import '../screens/republic_acts.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/library_screen.dart';
// import '../screens/intro_section.dart';
import '../screens/login_screen.dart';
import '../screens/notification.dart';
// import 'package:DILGDOCS/screens/library_screen.dart';

class Routes {
  static const String home = '/home';
  static const String search = '/search';
  static const String library = '/library';
  // static const String introsection = '/introsection';
  static const String latestIssuances = '/latest-issuances';
  static const String jointCirculars = '/joint-circulars';
  static const String memoCirculars = '/memo-circulars';
  static const String presidentialDirectives = '/presidential-directives';
  static const String draftIssuances = '/draft-issuances';
  static const String republicActs = '/republic-acts';
  static const String legalOpinions = '/legal-opinions';
  static const String login = '/login';
  static const String setting = '/settings';
  static const String editUser = '/edit_user';
  static const String changePassword = '/change-password';
  static const String about = '/about';
  static const String notifications = '/notification';
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      home: (context) => HomeScreen(),
      search: (context) => SearchScreen(),
      library: (context) => LibraryScreen(
            onFileOpened: (fileName, filePath) {
              // Implement your logic when file is opened
              print('File opened: $fileName');
            },
            onFileDeleted: (filePath) {
              // Implement your logic when file is deleted
              print('File deleted: $filePath');
            },
          ),
      latestIssuances: (context) => LatestIssuances(),
      jointCirculars: (context) => JointCirculars(),
      memoCirculars: (context) => MemoCirculars(),
      presidentialDirectives: (context) => PresidentialDirectives(),
      draftIssuances: (context) => DraftIssuances(),
      republicActs: (context) => RepublicActs(),
      legalOpinions: (context) => LegalOpinions(),
      login: (context) => LoginScreen(
            title: 'login',
          ),
      editUser: (context) => EditUser(),
      changePassword: (context) => ChangePasswordScreen(),
      setting: (context) => SettingsScreen(),
      about: (context) => About(),
      notifications: (context) => NotificationScreen(),
    };
  }

  // static void navigateToLibrary(BuildContext context) {
  //   Navigator.pushNamed(context, library);
  // }
}
