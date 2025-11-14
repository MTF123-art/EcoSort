import 'package:flutter/material.dart';
import '../../../../core/router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Simulasi loading / init app
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'EcoSort',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Icon(Icons.eco, size: 150, color: Colors.green[800]),
            const SizedBox(height: 24),
            const SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                minHeight: 6,
                backgroundColor: Colors.black12,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Smart Waste\nSorting',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
