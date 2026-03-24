import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'colorscheme.dart';

void main() async {
  // Ensure Flutter bindings are initialized before any async work
  WidgetsFlutterBinding.ensureInitialized();


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
