import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'colorscheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(null),
          update: (context, auth, previous) => UserProvider(auth.accessToken),
        ),
      ],
      child: const Innovation(),
    ),
  );
}

class Innovation extends StatelessWidget {
  const Innovation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innovation Coach',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      darkTheme: appDarkTheme(),
      builder: (context, child) {
        final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
        if (!isAuthenticated) {
          return const LoginScreen();
        }
        return child!;
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(title: 'Innovation Coach'),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
