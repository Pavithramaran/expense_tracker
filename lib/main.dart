import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expences_tracker/widgets/expences.dart'; // Ensure this import is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  ).then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 96, 59, 181),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 96, 59, 181),
        ),
        cardTheme: CardTheme(
          color: const Color.fromARGB(255, 96, 59, 181).withOpacity(0.1),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 96, 59, 181),
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(
            color: Color.fromARGB(255, 96, 59, 181),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 5, 99, 125),
        ),
        cardTheme: CardTheme(
          color: const Color.fromARGB(255, 5, 99, 125).withOpacity(0.1),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 5, 99, 125),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const LogoPage(), // Set LogoPage as the initial screen
    );
  }
}
// LogoPage to display the logo
class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/expenzlogo.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
// Utility function to sanitize email by replacing "." with "_"
String sanitizeEmail(String email) {
  return email.replaceAll('.', '_');
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('users'); // Firebase Realtime Database reference

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String sanitizedEmail = sanitizeEmail(_emailController.text);
      DatabaseReference userRef = _dbRef.child(sanitizedEmail);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        String storedPassword = snapshot.value.toString();
        if (storedPassword == _passwordController.text) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                userName: sanitizedEmail,
                userEmail: _emailController.text,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid password")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white), // Outer border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white), // Focused border color
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.white), // Icon color
                  labelStyle: const TextStyle(color: Colors.white), // Label color
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white), // Outer border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white), // Focused border color
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white), // Icon color
                  labelStyle: const TextStyle(color: Colors.white), // Label color
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    foregroundColor: Colors.black, // Button text color
                  ),
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text('Don\'t have an account? Sign Up', style: TextStyle(color: Colors.white)), // Button text color
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('users'); // Firebase Realtime Database reference

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      String sanitizedEmail = sanitizeEmail(_emailController.text);
      DatabaseReference userRef = _dbRef.child(sanitizedEmail);

      DataSnapshot snapshot = await userRef.get();
      if (!snapshot.exists) {
        // Store the new user's data
        await userRef.set(_passwordController.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userName: sanitizedEmail,
              userEmail: _emailController.text,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User already exists")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white), // Change label text color to white
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email, color: Colors.white), // Change icon color to white
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white), // Change focused border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white), // Change enabled border color
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white), // Change label text color to white
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white), // Change icon color to white
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white), // Change focused border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white), // Change enabled border color
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    foregroundColor: Colors.black, // Button text color
                  ),
                  onPressed: _signUp,
                  child: const Text('Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class HomePage extends StatelessWidget {
  final String userName;
  final String userEmail;

  const HomePage({super.key, required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Expences(
        userName: userName,
        userEmail: userEmail,
      ),
    );
  }
}
