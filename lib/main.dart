import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/method_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/library_screen.dart';
import 'screens/workshop_screen.dart';
import 'screens/favorites_screen.dart';
import 'colorscheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(null),
          update: (context, auth, previous) {
            if (previous != null) {
              previous.updateToken(auth.accessToken);
              return previous;
            }
            return UserProvider(auth.accessToken);
          },
        ),
        ChangeNotifierProvider(create: (context) => MethodProvider()),
      ],
      child: const Coach(),
    ),
  );
}

class Coach extends StatelessWidget {
  const Coach({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coach',
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
        '/': (context) => const HomePage(title: 'Coach'),
        '/profile': (context) => const ProfileScreen(),
        '/library': (context) => const LibraryScreen(),
        '/workshop': (context) => const WorkshopScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
    );
  }
}
