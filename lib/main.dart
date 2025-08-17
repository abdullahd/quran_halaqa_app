import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quran_halaqa_app/features/halaqa_list/presentation/halaqa_list_screen.dart'; // سننشئ هذا الملف قريباً
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const QuranHalaqaApp());
}

class QuranHalaqaApp extends StatelessWidget {
  const QuranHalaqaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سجل الحلقات',
      debugShowCheckedModeBanner: false,
      // --- بداية إعدادات اللغة العربية ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''), // العربية
      ],
      locale: const Locale('ar', ''),
      // --- نهاية إعدادات اللغة العربية ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF14532D)), // تم تغيير اللون الرئيسي
        textTheme: GoogleFonts.almaraiTextTheme(),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF14532D), // Match primary
          foregroundColor: Colors.white,
        ),
      ),
      home: HalaqaListScreen(), // هذه ستكون شاشتنا الرئيسية
    );
  }
}
