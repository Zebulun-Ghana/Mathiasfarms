import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:agromat_project/auth/auth_service.dart';
import 'package:agromat_project/models/app_user.dart';
import 'package:agromat_project/screens/home_screen.dart';
import 'package:agromat_project/screens/admin/admin_home_screen.dart';
import 'package:agromat_project/auth/login_screen.dart';
import 'package:agromat_project/providers/cart_provider.dart';
import 'package:agromat_project/services/onboarding_service.dart';
import 'package:agromat_project/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Agromat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: const Color(0xFF145A32),
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF145A32),
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF145A32),
              foregroundColor: Colors.white,
              textStyle: TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: OnboardingService.isOnboardingCompleted(),
      builder: (context, onboardingSnapshot) {
        if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF145A32),
              ),
            ),
          );
        }

        // Check if onboarding is completed
        if (onboardingSnapshot.data == null || !onboardingSnapshot.data!) {
          return const OnboardingScreen();
        }

        // Onboarding completed, proceed with auth check
        return StreamBuilder(
          stream: AuthService().userChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF145A32),
                  ),
                ),
              );
            }

            // Check if user is logged in
            if (snapshot.hasData && snapshot.data != null) {
              // User is logged in, check their role
              return FutureBuilder<AppUser?>(
                future: AuthService().getUserProfile(snapshot.data!.uid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF145A32),
                        ),
                      ),
                    );
                  }

                  final user = userSnapshot.data;
                  if (user?.role == 'admin') {
                    return const AdminHomeScreen();
                  } else {
                    return const HomeScreen();
                  }
                },
              );
            }

            // User is not logged in
            return const LoginScreen();
          },
        );
      },
    );
  }
}
