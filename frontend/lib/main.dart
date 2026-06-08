import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/budget_screen.dart';

void main() {
  runApp(const SmartBudgetApp());
}

class SmartBudgetApp extends StatelessWidget {
  const SmartBudgetApp({super.key});

  static const Color _primary = Color(0xFF6C63FF);       // electric violet
  static const Color _surface = Color(0xFF1E1E2C);       // dark surface
  static const Color _background = Color(0xFF121220);    // deep background
  static const Color _onPrimary = Colors.white;
  static const Color _onSurface = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'SmartBudget',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: _primary,
            onPrimary: _onPrimary,
            surface: _surface,
            onSurface: _onSurface,
            background: _background,
            onBackground: _onSurface,
            secondary: _primary.withOpacity(0.7),
            onSecondary: _onPrimary,
          ),
          scaffoldBackgroundColor: _background,
          cardTheme: CardThemeData(
            color: _surface,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: _surface,
            foregroundColor: _onSurface,
            elevation: 0,
            centerTitle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: _onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: _surface.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            labelStyle: const TextStyle(color: Color(0xFFB0B0C0)),
          ),
        ),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/add-transaction': (_) => const AddTransactionScreen(),
          '/budgets': (_) => const BudgetScreen(),
        },
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    await context.read<AuthProvider>().tryAutoLogin();
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = context.watch<AuthProvider>().user;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
      return const SizedBox.shrink();
    }
    return const LoginScreen();
  }
}
