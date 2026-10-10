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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

class TrackFinanceApp extends StatelessWidget {
  final String initialRoute;

  const TrackFinanceApp({
    super.key,
    this.initialRoute = '/splash',
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackFinance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/category': (context) => const CategoryScreen(),
        '/add-transaction': (context) => const AddTransactionScreen(),
        '/export': (context) => const ExportDataScreen(),
        '/report': (context) => const ReportScreen(),
      },
    );
  }
}
