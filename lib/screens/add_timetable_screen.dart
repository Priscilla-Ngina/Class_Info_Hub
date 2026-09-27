import 'package:flutter/material.dart';
import '../services/timetable_service.dart';

class AddTimetableScreen extends StatefulWidget {
  final String classId;

  const AddTimetableScreen({
    super.key,
    required this.classId,
  });

  @override
  State<AddTimetableScreen> createState() =>
      _AddTimetableScreenState();
}

class _AddTimetableScreenState
    extends State<AddTimetableScreen> {
  final unitController = TextEditingController();
  final timeController = TextEditingController();
  final roomController = TextEditingController();

  String selectedDay = 'Monday';

  bool isLoading = false;

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Future<void> addTimetableEntry() async {
    final unit = unitController.text.trim();
    final time = timeController.text.trim();
    final room = roomController.text.trim();

    if (unit.isEmpty || time.isEmpty || room.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await TimetableService().addTimetableEntry(
        classId: widget.classId,
        day: selectedDay,
        unit: unit,
        time: time,
        room: room,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timetable entry added'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add timetable entry: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    unitController.dispose();
    timeController.dispose();
    roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
        Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add Timetable Entry'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              decoration: const InputDecoration(
                labelText: 'Day',
                border: OutlineInputBorder(),
              ),
              items: days.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedDay = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unit',
                hintText:
                'e.g. SCO 304 Advanced Database Systems',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Time',
                hintText: 'e.g. 10:00 AM - 12:00 PM',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: roomController,
              decoration: const InputDecoration(
                labelText: 'Room',
                hintText: 'e.g. ICT Lab 2',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                isLoading ? null : addTimetableEntry,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                  'Add Timetable Entry',
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