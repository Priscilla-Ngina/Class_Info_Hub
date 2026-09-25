import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService authService = AuthService();
  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final registrationNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> createAccount() async {

    if(!formKey.currentState!.validate()){
      return;
    }

    if(passwordController.text != confirmPasswordController.text){
         print('Passwords do not match');
      return;
    }

    await authService.createAccount(
      email: emailController.text.trim(),
      password: passwordController.text,
      fullName: fullNameController.text.trim(),
      registrationNumber: registrationNumberController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Class Info Hub'),
      ),
      body: Center(
        child: Form(
          key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

            SizedBox(
              width: 300,
              child: TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),

                validator: (value){
                  if(value==null || value.isEmpty){
                    return 'Please enter your full name';
                  }
                  return null;
                },

              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: 300,
              child: TextFormField(
                controller: registrationNumberController,
                decoration: InputDecoration(
                  labelText: 'Registration Number',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your registration number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: 300,
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),

                validator: (value){
                  if(value==null || value.isEmpty){
                    return 'Please enter your email';
                  }

                  if(!value.contains('@')|| !value.contains('.')){
                    return 'Please enter a valid email';
                  }

                  return null;
                },

              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: 300,
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),

                validator: (value){
                  if(value==null || value.isEmpty){
                    return 'Please enter your password';
                  }

                  if(value.length<6){
                    return 'Password must be at least 6 characters';
                  }
                    return null;
                },

              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: 300,
              child: TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),

                validator: (value){
                  if(value==null || value.isEmpty){
                    return 'Please confirm your password';
                  }

                  if(value!=passwordController.text){
                    return 'Passwords do not match';
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
                onPressed: createAccount,
                child: const Text(
                  'Create Account',
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
                const Text('Already have an account? '),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Log in'),
                ),
              ],
            ),

          ],
        ),
        ),
      ),
    );
  }
}