import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hnizdo/models/current_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hnizdo/providers/auth_provider.dart';

// Provider for dark mode preference
final isDarkModeProvider = StateProvider<bool>((ref) {
  // Default to system theme
  return false;
});

// App state class
class AppState {
  final CurrentUser currentUser;
  final bool isDarkMode;

  AppState({
    CurrentUser? currentUser,
    this.isDarkMode = false,
  }) : currentUser = currentUser ?? const CurrentUser();

  AppState copyWith({
    CurrentUser? currentUser,
    bool? isDarkMode,
  }) {
    return AppState(
      currentUser: currentUser ?? this.currentUser,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  AppState removeUser() {
    return AppState(
      currentUser: null,
    );
  }

  // Helper properties
  bool get isLoggedIn => currentUser.isLoggedIn;
  String get userId => currentUser.uid;
}

class AppStateNotifier extends StateNotifier<AppState> {
  final DatabaseReference _database;
  final Ref _ref;

  AppStateNotifier(this._database, this._ref) : super(AppState()) {
    _initState();
  }

  Future<void> _initState() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;

    state = state.copyWith(isDarkMode: isDarkMode);

    // Notify the isDarkModeProvider
    _ref.read(isDarkModeProvider.notifier).state = isDarkMode;
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    final newTheme = !state.isDarkMode;

    // Update state
    state = state.copyWith(isDarkMode: newTheme);

    // Update provider
    _ref.read(isDarkModeProvider.notifier).state = newTheme;

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newTheme);
  }

  // Set user data
  Future<void> setUserData(CurrentUser user) async {
    state = state.copyWith(currentUser: user);
  }

  // Sign out
  void signOut() {
    state = state.removeUser();
  }
}

// App state provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  final database = ref.watch(databaseProvider);
  return AppStateNotifier(database, ref);
});