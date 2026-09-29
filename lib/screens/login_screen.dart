
import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
const LoginScreen({super.key});

@override
State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
final emailController = TextEditingController();
final passwordController = TextEditingController();
final formKey = GlobalKey<FormState>();

Future<void> login() async {
  if (!formKey.currentState!.validate()) {
    return;
  }

  try {
    await AuthService().login(
email: emailController.text.trim(),
password: passwordController.text,
);

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const HomeScreen(),
),
);
} on FirebaseAuthException catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Invalid email or password.'),
),
);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
backgroundColor:
Theme.of(context).colorScheme.inversePrimary,
title: const Text('Class Info Hub'),
),
body: SingleChildScrollView(
child: Padding(
padding: const EdgeInsets.symmetric(vertical: 24),
  child: Form(
    key: formKey,
    child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text(
'📢',
style: TextStyle(
fontSize: 50,
),
),
const SizedBox(height: 8),
const Text(
'CLASS INFO HUB',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 24),
const Text(
'Welcome back 👋',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
const Text(
'Log in to continue',
style: TextStyle(
fontSize: 16,
),
),
const SizedBox(height: 24),
SizedBox(
width: 300,
child: TextFormField(
  controller: emailController,
  decoration: const InputDecoration(
    labelText: 'Email',
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    return null;
  },
),
),
const SizedBox(height: 16),
SizedBox(
width: 300,
child:TextFormField(
  controller: passwordController,
  obscureText: true,
  decoration: const InputDecoration(
    labelText: 'Password',
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    return null;
  },
),
),
const SizedBox(height: 24),
SizedBox(
width: 300,
height: 50,
child: ElevatedButton(
onPressed: login,
child: const Text(
'Log In',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
),
),
const SizedBox(height: 16),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text("Don't have an account? "),
TextButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
const RegisterScreen(),
),
);
},
child: const Text('Create one'),
),
],
),
],
),
),
),
),
);
}
}
