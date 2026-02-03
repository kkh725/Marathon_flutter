import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'models/marathon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MarathonAdapter());
  Hive.registerAdapter(EntryMethodAdapter());
  Hive.registerAdapter(DifficultyAdapter());

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: MarathonApp(),
    ),
  );
}

class MarathonApp extends StatelessWidget {
  const MarathonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K-RUN GLOBAL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.notoSansKrTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
