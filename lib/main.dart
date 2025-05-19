import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hnizdo/app_theme.dart';
import 'package:hnizdo/screens/splash_screen.dart';
import 'package:hnizdo/states/app_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hnizdo/states/language_state.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    // Configure Firebase Database to persist data
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }

  // Run the app
  runApp(
    ProviderScope(
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read theme from the app state
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'Hnizdo',
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      locale: ref.watch(languageProvider).locale,
      supportedLocales: const [
        Locale('en'),
        Locale('uk'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
