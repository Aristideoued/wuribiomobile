import 'package:wuriproject/Screens/Authentification.dart';
import 'package:wuriproject/Screens/EnrollPage.dart';
import 'package:wuriproject/Screens/Home.dart';

final routes = {
  '/': (context) => const AuthHomePage(), // ← PAS WuriAuthApp ici
  '/enroll': (context) => const EnrollPage(),
  '/authentification': (context) =>  BiometricAuthPage(),
};