import 'package:flutter/material.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/scan/presentation/pages/scan_page.dart';
import '../features/scan/presentation/pages/scan_result_page.dart';
import '../features/scan/domain/entities/scan_result.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const history = '/history';
  static const scan = '/scan';
  static const scanResult = '/scan/result';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashPage());
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomePage());
    case AppRoutes.history:
      return MaterialPageRoute(builder: (_) => const HistoryPage());
    case AppRoutes.scan:
      return MaterialPageRoute(builder: (_) => const ScanPage());
    case AppRoutes.scanResult:
      final args = settings.arguments;
      if (args is ScanResult) {
        return MaterialPageRoute(builder: (_) => ScanResultPage(result: args));
      }
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('ScanResult data missing')),
        ),
      );
    default:
      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Route not found'))),
      );
  }
}
