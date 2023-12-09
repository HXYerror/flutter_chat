import 'package:awesome_help/pages/home.dart';
import 'package:awesome_help/pages/login.dart';
import 'package:awesome_help/pages/second.dart';
import 'package:awesome_help/pages/setting.dart';
import 'package:get/get.dart';

final routes = [
  GetPage(name: '/', page: () => MyHomePage()),
  GetPage(name: '/second', page: () => const SecondPage()),
  GetPage(name: '/setting', page: () => SettingPage()),
  GetPage(name: '/login', page: () => const LoginPage())
];
