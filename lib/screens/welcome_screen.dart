import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget{
  const WelcomeScreen({super.key});

  @override
  Widget build( BuildContext context){
return Scaffold(
  appBar: AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    title: const Text('Class Info Hub'),
  ),

  body: Center(
child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [

    const Text(
      'Welcome to Class Info Hub',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),

   const SizedBox(height:16),

   const Text(
      'Official class communication, all in one place',
      style: TextStyle(
        fontSize:16,
      ),
    ),

    const SizedBox(height: 24),

     SizedBox(
      width:200,
      height:50,
      child:ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () {},
        child: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

      ),
    ),

  ],
),
  ),
);
  }
}