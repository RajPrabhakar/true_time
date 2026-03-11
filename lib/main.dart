import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/services/theme_service.dart';
import 'screens/home_screen.dart';
import 'providers/true_time_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();
  await themeService.initialize();
  final savedThemeId = themeService.getSavedThemeId();
  final initialTheme =
      ThemeProvider.themeFromId(savedThemeId) ?? AppThemeType.void_;
  final hasPro = themeService.isProUnlocked();

  runApp(
    MainApp(
      themeService: themeService,
      initialTheme: initialTheme,
      hasPro: hasPro,
    ),
  );
}

class MainApp extends StatelessWidget {
  final ThemeService themeService;
  final AppThemeType initialTheme;
  final bool hasPro;

  const MainApp({
    super.key,
    required this.themeService,
    required this.initialTheme,
    required this.hasPro,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(
            themeService: themeService,
            initialTheme: initialTheme,
            initialHasPro: hasPro,
          ),
        ),
        ChangeNotifierProvider(create: (_) => TrueTimeProvider()),
      ],
      child: const MaterialApp(
        home: HomeScreenWrapper(),
      ),
    );
  }
}

/// Wrapper that ensures ThemeProvider is initialized before showing HomeScreen
class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> {
  late Future<void> _initThemeFuture;

  @override
  void initState() {
    super.initState();
    _initThemeFuture = context.read<ThemeProvider>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initThemeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const HomeScreen();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
