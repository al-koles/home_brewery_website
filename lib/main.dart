import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:home_brewery_website/components/authorization.dart';
import 'package:home_brewery_website/translations/codegen_loader.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('uk')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    assetLoader: const CodegenLoader(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Home Brewery',
      home: const Authorization()
    );
  }
}

