import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'graph/graph_controller.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GraphController(),
      child: Consumer<GraphController>(
        builder: (context, controller, child) {
          return MaterialApp(
            title: 'MusicGraph AI',
            debugShowCheckedModeBanner: false,
            themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            
            // --- Premium Futuristic Light Theme ---
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0288D1),
                brightness: Brightness.light,
                background: const Color(0xFFF3F5F9), // Ice blue / clean grey
                surface: Colors.white,
                primary: const Color(0xFF0288D1),
                secondary: const Color(0xFF7B1FA2),
                tertiary: const Color(0xFF2E7D32),
              ),
              scaffoldBackgroundColor: const Color(0xFFF3F5F9),
              cardTheme: CardThemeData(
                color: Colors.white.withOpacity(0.9),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF0288D1).withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color(0xFF0288D1);
                  }
                  return Colors.grey;
                }),
                trackColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color(0xFF0288D1).withOpacity(0.4);
                  }
                  return Colors.grey.withOpacity(0.2);
                }),
              ),
              fontFamily: 'Roboto',
              textTheme: const TextTheme(
                titleLarge: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
                bodyLarge: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),

            // --- Premium Cyberpunk Dark Theme ---
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF00E5FF),
                brightness: Brightness.dark,
                background: const Color(0xFF0A0D14),
                surface: const Color(0xFF111422),
                primary: const Color(0xFF00E5FF),
                secondary: const Color(0xFFBD00FF),
                tertiary: const Color(0xFF00FF87),
              ),
              scaffoldBackgroundColor: const Color(0xFF0A0D14),
              cardTheme: CardThemeData(
                color: const Color(0xFF111422).withOpacity(0.8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF00E5FF).withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color(0xFF00E5FF);
                  }
                  return Colors.grey;
                }),
                trackColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color(0xFF00E5FF).withOpacity(0.4);
                  }
                  return Colors.grey.withOpacity(0.2);
                }),
              ),
              fontFamily: 'Roboto',
              textTheme: const TextTheme(
                titleLarge: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
                bodyLarge: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
