import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:musiz_player/generated/l10n.dart';
import 'package:musiz_player/providers/audio_handler.dart';
import 'package:musiz_player/providers/media_manager.dart';
import 'package:musiz_player/providers/theme_manager.dart';
import 'package:musiz_player/services/server.dart';
import 'package:musiz_player/ui/themes/dark.dart';
import 'package:musiz_player/ui/themes/light.dart';
import 'package:musiz_player/utils/playback_cache.dart';
import 'package:musiz_player/utils/router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  MetadataGod.initialize();
  await openBox('HomeCache');
  await openBox('settings');
  await openBox('downloads');
  await openBox('favorites');
  await openBox('songHistory');
  await openBox('searchHistory');
  await openBox('playlists');

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  GetIt.I.registerSingleton<AudioHandler>(await initAudioService());
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  GetIt.I.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);
  MediaManager mediaManager = MediaManager();
  ThemeManager themeManager = ThemeManager();
  GetIt.I.registerSingleton(mediaManager);
  GetIt.I.registerSingleton(themeManager);
  GetIt.I.registerSingleton(PlaybackCache());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => themeManager),
        ChangeNotifierProvider(create: (context) => mediaManager),
      ],
      child: const MainApp(),
    ),
  );
  if (Platform.isLinux) {
    doWhenWindowReady(() {
      const initialSize = Size(1280, 720);
      // appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late HttpServer httpServer;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    httpServer = await startServer();
  }

  @override
  void dispose() {
    super.dispose();
    httpServer.close();
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager themeManager = context.watch<ThemeManager>();
    return DynamicColorBuilder(
      builder: (lightScheme, darkScheme) {
        return MaterialApp.router(
          title: 'Musiz Play',
          locale: Locale(themeManager.language['code']),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          theme:
              themeManager.isMaterialTheme && darkScheme != null
                  ? materialLightTheme(darkScheme.primary)
                  : themeManager.getLightTheme,
          darkTheme:
              themeManager.isMaterialTheme && lightScheme != null
                  ? materialDarkTheme(lightScheme.primary)
                  : themeManager.getDarkTheme,
          themeMode: themeManager.themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

Future<Box<E>> openBox<E>(String name) async {
  return await Hive.openBox(
    name,
    path: Platform.isAndroid ? null : 'Xoxo Play',
  );
}
