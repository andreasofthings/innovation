import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/method_provider.dart';
import 'providers/workshop_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/workshop_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/chat_screen.dart';
import 'models/workshop.dart';
import 'colorscheme.dart';
import 'widgets/main_shell.dart';

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
        ChangeNotifierProvider(create: (context) => WorkshopProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
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
      onGenerateRoute: (settings) {
        if (settings.name == '/workshop-detail') {
          final workshop = settings.arguments as Workshop;
          return MaterialPageRoute(
            builder: (context) => WorkshopDetailScreen(workshop: workshop),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const MainShell(),
        '/profile': (context) => const ProfileScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
