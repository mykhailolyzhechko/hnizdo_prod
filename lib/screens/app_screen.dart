import 'package:hnizdo/screens/home_screen.dart';
import 'package:hnizdo/screens/profile_screen.dart';
import 'package:hnizdo/states/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hnizdo/states/language_state.dart';

class AppScreen extends ConsumerStatefulWidget {
  static String tag = '/AppScreen';

  const AppScreen({super.key});

  @override
  ConsumerState<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends ConsumerState<AppScreen> {
  int screenCurrentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get localized strings
    final l10n = AppLocalizations.of(context)!;

    // Get current app state
    final appState = ref.watch(appStateProvider);
    final localeState = ref.watch(languageProvider);
    final isDarkMode = appState.isDarkMode;
    final currentLocale = localeState.locale;

    final tabs = const [HomeScreen(), ProfileScreen()];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          // Add a theme toggle switch
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(appStateProvider.notifier).toggleTheme();
            },
          ),

          // Add language selector
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) {
              ref.read(languageProvider.notifier).setLocale(locale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              PopupMenuItem<Locale>(
                value: const Locale('en'),
                child: Row(
                  children: [
                    if (currentLocale.languageCode == 'en')
                      const Icon(Icons.check, size: 16),
                    const SizedBox(width: 8),
                    const Text('English'),
                  ],
                ),
              ),
              PopupMenuItem<Locale>(
                value: const Locale('uk'),
                child: Row(
                  children: [
                    if (currentLocale.languageCode == 'uk')
                      const Icon(Icons.check, size: 16),
                    const SizedBox(width: 8),
                    const Text('Українська'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: tabs[screenCurrentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        enableFeedback: false,
        backgroundColor: Colors.blueGrey[50],
        currentIndex: screenCurrentIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blueGrey,
        onTap: (index) {
          setState(() {
            screenCurrentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home, color: Colors.grey),
            activeIcon: const Icon(Icons.home, color: Colors.blueGrey),
            label: l10n.dashboard,
            tooltip: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, color: Colors.grey),
            activeIcon: const Icon(Icons.person, color: Colors.blueGrey),
            label: l10n.profile,
            tooltip: l10n.profile,
          ),
        ],
      ),
    );
  }
}
