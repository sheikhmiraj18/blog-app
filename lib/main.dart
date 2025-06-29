import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/signup_screen.dart';
import 'providers/auth_provider.dart' as my_auth;
import 'screens/auth/login_screen.dart';
import 'screens/home/explore_screen.dart';
import 'screens/blog/create_blog_screen.dart';
import 'models/user_model.dart';
import 'screens/home/profile_screen.dart';
import 'screens/home/following_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => my_auth.AuthProvider()..loadUser(),
      child: MaterialApp(
        title: 'Blog App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const ExploreScreen(),
          '/signup': (context) => const SignupScreen(),
          '/login': (context) => const LoginScreen(),
        },


        onGenerateRoute: (settings) {
          if (settings.name == '/create-blog') {
            final args = settings.arguments;
            if (args is AppUser) {
              return MaterialPageRoute(
                builder: (_) => CreateBlogScreen(currentUser: args),
              );
            } else {
              return _errorRoute("Invalid arguments for create-blog.");
            }
          }
        },
      ),
    );
  }

  Route _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}


class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<my_auth.AuthProvider>(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) return const LoginScreen();

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return HomeScreen(user: authProvider.user!);
  }

}

class HomeScreen extends StatefulWidget {
  final AppUser user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    print("Building HomeScreen with index $_currentIndex");

    final screens = [
      const ExploreScreen(),
      CreateBlogScreen(
        currentUser: widget.user,
        onPostSuccess: () => setState(() => _currentIndex = 0),
      ),
      const ProfileScreen(),
      const FollowingScreen(),
    ];


    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Material(
        elevation: 10,
        color: Colors.white,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Following'),
          ],
        ),
      ),


    );
  }
}
