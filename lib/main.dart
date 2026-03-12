import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hype_grid/utils/app_theme.dart';
import 'package:hype_grid/pages/splash/splash_screen.dart';
import 'package:hype_grid/services/supabase_service.dart';
import 'package:hype_grid/pages/detail/event_detail_screen.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hype_grid/utils/environment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path),
  );

  // Load environment variables based on APP_ENV flag
  await dotenv.load(fileName: Environment.envFileName);
  
  debugPrint('Running in ${Environment.current.name} mode, loading ${Environment.envFileName}');

  // Initialize Supabase
  await SupabaseService().initialize();

  runApp(const HypeGridApp());
}

class HypeGridApp extends StatelessWidget {
  const HypeGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
