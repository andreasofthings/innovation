import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'colorscheme.dart';

void main() async {
  // Ensure Flutter bindings are initialized before any async work
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables with error handling
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Could not load .env file. Ensure it exists in the root directory.");
    // We continue execution; the AuthProvider will handle missing variables gracefully or throw errors when used.
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const Innovation(),
    ),
  );
}

class Innovation extends StatelessWidget {
  const Innovation({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the authentication state from the AuthProvider
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;

    return MaterialApp(
      title: 'Innovation Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: schema(),
        useMaterial3: true,
      ),
      // Automatically toggle between Login and Home based on auth state
      home: isAuthenticated
          ? const HomePage(title: 'Innovation Coach')
          : const LoginScreen(),
    );
  }
}
