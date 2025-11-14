import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router.dart';
import 'theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../features/scan/data/gemini_client.dart';
import '../features/scan/data/scan_repository.dart';
import '../features/scan/presentation/controllers/scan_controller.dart';
import '../features/history/data/history_database.dart';
import '../features/history/data/history_repository.dart';
import '../features/history/presentation/controllers/history_controller.dart';

class EcoSortApp extends StatelessWidget {
  const EcoSortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Dio>(
          create: (_) => Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ),
          ),
        ),
        ProxyProvider<Dio, GeminiClient>(
          update: (_, dio, __) =>
              GeminiClient(dio, apiKey: dotenv.env['GEMINI_API_KEY'] ?? ''),
        ),
        ProxyProvider<GeminiClient, ScanRepository>(
          update: (_, client, __) => ScanRepository(client),
        ),
        // History providers must be above consumers
        Provider<HistoryDatabase>(create: (_) => HistoryDatabase.instance),
        ProxyProvider<HistoryDatabase, HistoryRepository>(
          update: (_, db, __) => HistoryRepository(db),
        ),
        ChangeNotifierProxyProvider2<
          ScanRepository,
          HistoryRepository,
          ScanController
        >(
          create: (_) => ScanController(),
          update: (_, repo, history, ctrl) => ctrl!
            ..attach(repo)
            ..attachHistory(history),
        ),
        ChangeNotifierProxyProvider<HistoryRepository, HistoryController>(
          create: (_) => HistoryController(),
          update: (_, repo, ctrl) => ctrl!..attach(repo),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EcoSort',
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
