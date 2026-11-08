import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/category/presentation/screens/category_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/transaction/presentation/screens/add_transaction_screen.dart';
import 'features/export/presentation/screens/export_data_screen.dart';
import 'features/report/presentation/screens/report_screen.dart';

import 'features/splash/presentation/screens/splash_screen.dart';

/// Batas memori cache gambar & penyimpanan lokal agar aplikasi tetap hemat RAM
/// pada perangkat Android berspesifikasi rendah (1–2 GB RAM).
void configureLowSpecPerformanceBudgets() {
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 100; // Maksimal 100 bitmap aktif (default: 1000)
  imageCache.maximumSizeBytes = 24 << 20; // 24 MB batas tekstur (default: 100 MB)
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureLowSpecPerformanceBudgets();

  try {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 20 * 1024 * 1024, // 20 MB batas disk cache (default: 100 MB)
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  // Set system UI overlay style for seamless edge-to-edge light theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TrackFinanceApp());
}

class TrackFinanceApp extends StatefulWidget {
  final String initialRoute;

  const TrackFinanceApp({
    super.key,
    this.initialRoute = '/splash',
  });

  @override
  State<TrackFinanceApp> createState() => _TrackFinanceAppState();
}

class _TrackFinanceAppState extends State<TrackFinanceApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    // Bebaskan bitmap dekode yang tidak aktif saat Android mengirim sinyal tekanan RAM
    PaintingBinding.instance.imageCache.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Kosongkan cache gambar non-aktif saat aplikasi berpindah ke background
      // agar proses aplikasi tidak mudah dimatikan oleh Android Low Memory Killer (LMK).
      PaintingBinding.instance.imageCache.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackFinance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: widget.initialRoute,
      onGenerateRoute: (settings) {
        final instantScreens = <String, WidgetBuilder>{
          '/profile': (context) => const ProfileScreen(),
          '/category': (context) => const CategoryScreen(),
          '/add-transaction': (context) => const AddTransactionScreen(),
          '/export': (context) => const ExportDataScreen(),
          '/report': (context) => const ReportScreen(),
        };

        if (instantScreens.containsKey(settings.name)) {
          return PageRouteBuilder(
            settings: settings,
            opaque: true,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (context, animation, secondaryAnimation) =>
                instantScreens[settings.name]!(context),
          );
        }
        return null;
      },
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
