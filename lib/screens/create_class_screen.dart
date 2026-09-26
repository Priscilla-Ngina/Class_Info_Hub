import 'package:flutter/material.dart';
import '../services/class_service.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final programmeController = TextEditingController();
  final yearController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String generateClassCode(String programme, String year) {
    final words = programme
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();

    String programmeCode;

    if (words.length >= 2) {
      programmeCode = words
          .map((word) => word[0])
          .join()
          .substring(0, 2)
          .toUpperCase();
    } else {
      programmeCode = words[0]
          .substring(0, 2)
          .toUpperCase();
    }

    final yearCode = year.trim();

    final uniqueNumber =
    DateTime.now().millisecondsSinceEpoch.toString().substring(8);

    return '$programmeCode$yearCode$uniqueNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create a Class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const Text(
                'Create a Class',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: programmeController,
                decoration: const InputDecoration(
                  labelText: 'Programme',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your programme';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  hintText: 'Enter your year, e.g. 3',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your year';
                  }

                  if (int.tryParse(value.trim()) == null) {
                    return 'Year must be a number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final classCode = generateClassCode(
                        programmeController.text,
                        yearController.text,
                      );

                      await ClassService().createClass(
                        programme: programmeController.text.trim(),
                        year: yearController.text.trim(),
                        classCode: classCode,
                      );
                    }
                  },
                  child: const Text(
                    'Create Class',
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
      ),
    );
  }
}