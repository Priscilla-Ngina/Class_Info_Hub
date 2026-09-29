import 'package:flutter/material.dart';
import '../services/class_service.dart';
import 'class_space_screen.dart';

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final classCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Join a Class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Join a Class',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: classCodeController,
              decoration: const InputDecoration(
                labelText: 'Class Code',
                hintText: 'Enter your class code',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final classCode = classCodeController.text.trim();

                  if (classCode.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a class code'),
                      ),
                    );
                    return;
                  }

                  final results = await ClassService().findClassByCode(classCode);

                  if (results.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Class not found'),
                      ),
                    );
                    return;
                  }

                  final classId = results.docs.first.id;

                  print('About to join class: $classId');

                  await ClassService().joinClass(classId);

                  print('Successfully joined class');
                  final classData = results.docs.first.data() as Map<String, dynamic>;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassSpaceScreen(
                        classId: classId,
                        programme: classData['programme'],
                        year: classData['year'],
                        classCode: classData['classCode'],

                      ),
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Class found successfully!'),
                    ),
                  );                },

                child: const Text(
                  'Join Class',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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