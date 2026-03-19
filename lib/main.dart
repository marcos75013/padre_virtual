import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'features/splash/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('pt'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      child: const PadreApp(),
    ),
  );
}

class PadreApp extends StatelessWidget {
  const PadreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      home: const SplashScreen(),
    );
  }
}