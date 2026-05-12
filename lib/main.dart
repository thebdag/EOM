import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'theme/eom_theme.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.init();
  // Lock to dark status bar icons matching our dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const EomApp());
}

class EomApp extends StatelessWidget {
  const EomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EOM',
      debugShowCheckedModeBanner: false,
      theme: EomTheme.dark,
      home: const HomeScreen(),
    );
  }
}
