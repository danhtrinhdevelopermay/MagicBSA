import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/image_provider.dart';
import 'services/audio_service.dart';
import 'services/onesignal_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize audio service
  await AudioService().initialize();
  
  // Start background music automatically
  await AudioService().playBackgroundMusic();
  
  // Initialize OneSignal push notifications
  await OneSignalService.initialize();
  
  // Set transparent system bars with proper edge-to-edge
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));
  
  // Enable edge-to-edge mode for full immersive experience
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  
  runApp(const AIImageEditorApp());
}

class AIImageEditorApp extends StatelessWidget {
  const AIImageEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ImageEditProvider(),
      child: MaterialApp(
        title: 'Twink AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366f1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}