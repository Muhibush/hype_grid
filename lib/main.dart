import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hype_grid/utils/app_theme.dart';
import 'package:hype_grid/pages/splash/splash_screen.dart';
import 'package:hype_grid/services/supabase_service.dart';
import 'package:hype_grid/pages/detail/event_detail_screen.dart';
import 'package:hype_grid/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:hype_grid/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await SupabaseService().initialize();

  // Initialize Firebase (wrapped in try-catch in case config is missing)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const HypeGridApp());
}

class HypeGridApp extends StatefulWidget {
  const HypeGridApp({super.key});

  @override
  State<HypeGridApp> createState() => _HypeGridAppState();
}

class _HypeGridAppState extends State<HypeGridApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupInteractedMessage();
  }

  Future<void> _setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data.containsKey('event_id')) {
      final eventId = message.data['event_id'];
      _navigatorKey.currentState?.pushNamed('/event/$eventId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'HypeGrid',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/event/')) {
          final eventId = settings.name!.replaceFirst('/event/', '');
          return MaterialPageRoute(
            builder: (context) => EventDetailRouteWrapper(eventId: eventId),
          );
        }
        return null;
      },
    );
  }
}
