import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/posts/screens/home_screen.dart';
import 'features/posts/screens/post_detail_screen.dart';
import 'features/posts/screens/create_post_screen.dart';
import 'features/calculators/screens/calculators_screen.dart';
import 'features/calculators/screens/kobasice_calculator_screen.dart';
import 'features/calculators/screens/tripice_calculator_screen.dart';
import 'features/calculators/screens/tursija_calculator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KulinarApp()));
}

const kBg = Color(0xFF181818);
const kSurface = Color(0xFF242424);
const kCard = Color(0xFF2C2C2C);
const kOrange = Color(0xFFE85D04);
const kOrangeLight = Color(0xFFFF7B2C);

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => _Shell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/kalkulatori', builder: (_, __) => const CalculatorsScreen()),
      ],
    ),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/posts/create', builder: (_, __) => const CreatePostScreen()),
    GoRoute(
      path: '/posts/:slug',
      builder: (_, state) => PostDetailScreen(slug: state.pathParameters['slug']!),
    ),
    GoRoute(path: '/kalkulatori/kobasice', builder: (_, __) => const KobasiceCalculatorScreen()),
    GoRoute(path: '/kalkulatori/tripice', builder: (_, __) => const TripiceCalculatorScreen()),
    GoRoute(path: '/kalkulatori/tursija', builder: (_, __) => const TursijaCalculatorScreen()),
  ],
);

class KulinarApp extends ConsumerWidget {
  const KulinarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Kulinar.app',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: kOrange,
          secondary: kOrangeLight,
          surface: kSurface,
          onSurface: Colors.white,
          onPrimary: Colors.white,
          outline: kOrange,
        ),
        scaffoldBackgroundColor: kBg,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: kSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: kSurface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          indicatorColor: kOrange.withOpacity(0.15),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: kOrange, size: 26);
            }
            return const IconThemeData(color: Colors.white38, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: kOrange, fontWeight: FontWeight.w600, fontSize: 12);
            }
            return const TextStyle(color: Colors.white38, fontSize: 12);
          }),
        ),
        cardTheme: CardThemeData(
          color: kCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: kOrange, width: 1),
          ),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kOrange, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.white60),
          hintStyle: const TextStyle(color: Colors.white30),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        dividerTheme: const DividerThemeData(color: Colors.white12),
        iconTheme: const IconThemeData(color: kOrange),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white54),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _Shell extends ConsumerWidget {
  final Widget child;

  const _Shell({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/recepti') return 1;
    if (location.startsWith('/kalkulatori')) return 3;
    if (location == '/profil') return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider).isLoggedIn;
    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/posts/create'),
        backgroundColor: kOrange,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kSurface,
          border: const Border(top: BorderSide(color: kOrange, width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Početna', selected: _currentIndex(context) == 0, onTap: () => context.go('/')),
                _NavItem(icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: 'Recepti', selected: _currentIndex(context) == 1, onTap: () => context.go('/')),
                const SizedBox(width: 60), // prostor za FAB
                _NavItem(icon: Icons.calculate_outlined, selectedIcon: Icons.calculate, label: 'Kalkulator', selected: _currentIndex(context) == 3, onTap: () => context.go('/kalkulatori')),
                _NavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profil', selected: _currentIndex(context) == 4, onTap: () => context.push(isLoggedIn ? '/profil' : '/login')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? selectedIcon : icon,
              color: selected ? kOrange : Colors.white38,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? kOrange : Colors.white38,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
