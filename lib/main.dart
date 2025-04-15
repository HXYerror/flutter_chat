import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:awesome_help/controller/conversation.dart';
import 'package:awesome_help/controller/message.dart';
import 'package:awesome_help/controller/prompt.dart';
import 'package:awesome_help/controller/settings.dart';
import 'package:awesome_help/pages/unknown.dart';
import 'package:awesome_help/configs/translations.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:awesome_help/route.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  if (GetPlatform.isWindows) {
    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await GetStorage.init();
  FToastBuilder();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    Get.put(ConversationController());
    Get.put(MessageController());
    Get.put(PromptController());
    return GetMaterialApp(
      initialRoute: '/',
      getPages: routes,
      unknownRoute:
          GetPage(name: '/not_found', page: () => const UnknownRoutePage()),
      theme: FlexThemeData.light(scheme: FlexScheme.ebonyClay),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.ebonyClay),
      themeMode: ThemeMode.system,
      locale: const Locale('zh'),
      translations: MyTranslations(),
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
    );
  }
}
