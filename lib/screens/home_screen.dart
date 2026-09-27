import 'package:flutter/material.dart';
import '../services/class_service.dart';
import 'create_class_screen.dart';
import 'join_class_screen.dart';
import 'class_space_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ClassService classService = ClassService();

  List<Map<String, dynamic>> myClasses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMyClasses();
  }

  Future<void> loadMyClasses() async {
    try {
      final memberships = await classService.getMyMemberships();

      print('Memberships found: ${memberships.docs.length}');

      final List<Map<String, dynamic>> classes = [];

      for (final membership in memberships.docs) {
        final classId = membership.reference.parent.parent!.id;

        final classDocument = await classService.firestore
            .collection('classes')
            .doc(classId)
            .get();

        if (classDocument.exists) {
          final data = classDocument.data()!;

          final isManager =
          await classService.isClassManager(classId);

          classes.add({
            'classId': classId,
            'programme': data['programme'],
            'year': data['year'],
            'isManager': isManager,
          });
        }
      }

      if (mounted) {
        setState(() {
          myClasses = classes;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading classes: $e');

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Class Info Hub'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Class Info Hub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Your Classes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : myClasses.isEmpty
                  ? const Center(
                child: Text(
                  'You haven’t joined any classes yet.',
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                itemCount: myClasses.length,
                itemBuilder: (context, index) {
                  final classData = myClasses[index];

                  return Card(
                    child: ListTile(
                      title: Text(
                        classData['programme'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Year ${classData['year']}',
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ClassSpaceScreen(
                                  classId: classData['classId'],
                                  programme: classData['programme'],
                                  year: classData['year'],
                                  isManager: classData['isManager'],                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinClassScreen(),
                    ),
                  ).then((_) {
                    loadMyClasses();
                  });
                },
                child: const Text(
                  'Join a Class',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateClassScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Create a Class',
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