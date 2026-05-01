import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/preferences_service.dart';

// Global notifier — any widget can read/write the theme mode
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load persisted theme before the first frame
  themeModeNotifier.value = await PreferencesService.getThemeMode();

  final bool loggedIn = await AuthService.isLoggedIn();

  runApp(TayyibApp(
    startScreen: loggedIn ? const HomeScreen() : const LoginScreen(),
  ));
}

class TayyibApp extends StatelessWidget {
  final Widget startScreen;
  const TayyibApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: 'Tayyib',
        debugShowCheckedModeBanner: false,
        theme: TayyibTheme.light(),
        darkTheme: TayyibTheme.dark(),
        themeMode: mode,
        home: startScreen,
      ),
    );
  }
}
