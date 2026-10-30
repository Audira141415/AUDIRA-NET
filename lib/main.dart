import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/routes.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'utils/theme_provider.dart';
import 'dart:async';
import 'utils/seed_isp_users.dart';
import 'utils/seed_customers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Background non-blocking initial seeds (does not block cold start)
  unawaited(() async {
    try {
      await seedISPUsers();
    } catch (_) {}
    try {
      await seedCustomers();
    } catch (_) {}
  }());

  // Inisialisasi notification service
  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  runApp(const AudiraApp());
}

class AudiraApp extends StatelessWidget {
  const AudiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Audira Digital Network',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: Routes.authGate, // Fast session recovery and splash gate
            onGenerateRoute: RouteGenerator.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
