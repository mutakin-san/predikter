import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:predikter/pages/main_pages.dart';
import 'package:predikter/utils/themes.dart';
import 'package:provider/provider.dart';

import 'providers/history_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'id_ID';
  initializeDateFormatting('id_ID');

  runApp(const PredikterApp());
}

class PredikterApp extends StatelessWidget {
  const PredikterApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => HistoryProvider(),
      child: MaterialApp(
        title: 'Predikter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
          ).copyWith(onBackground: accentColor, onSurface: accentColor),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, textStyle: GoogleFonts.roboto()),
          ),
          textTheme: GoogleFonts.robotoSlabTextTheme().copyWith(
            titleMedium: GoogleFonts.robotoCondensed(
                fontWeight: FontWeight.bold, fontSize: 18),
            headlineMedium: GoogleFonts.robotoSerif(
                fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        home: AnimatedSplashScreen(
          splash: 'assets/images/logo.png',
          nextScreen: const MainPage(),
          splashTransition: SplashTransition.fadeTransition,
        ),
      ),
    );
  }
}
