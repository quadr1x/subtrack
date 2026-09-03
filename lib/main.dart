import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:subtrack/screens/main_screen.dart';
import 'package:subtrack/models/subscription.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await EasyLocalization.ensureInitialized();
  } catch (e, st) {
    debugPrint('EasyLocalization init failed: $e\n$st');
  }

  // Инициализация Hive
  try {
    await Hive.initFlutter();

    // Регистрация адаптера Hive (ДОЛЖНА выполняться до openBox<Subscription>)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SubscriptionAdapter());
    }

    // Открытие базы данных С ТИПОМ — иначе Hive.box<Subscription>(...) упадёт
    // с "The box is already open and of type Box<dynamic>".
    await Hive.openBox<Subscription>('subscriptions');
  } catch (e, st) {
    debugPrint('Hive init failed: $e\n$st');
    // Не даём приложению упасть молча — покажем понятную ошибку.
    runApp(_FatalBootError(error: e.toString(), stack: st.toString()));
    return;
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ru'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ru'),
      child: const MyApp(),
    ),
  );
}

/// Фолбэк-экран при ошибке инициализации (Hive / EasyLocalization).
class _FatalBootError extends StatelessWidget {
  final String error;
  final String stack;
  const _FatalBootError({required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF111114),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'SubTrack: ошибка запуска',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Не удалось инициализировать хранилище. '
                  'Удалите папку данных приложения и перезапустите его.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      '$error\n\n$stack',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubTrack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
