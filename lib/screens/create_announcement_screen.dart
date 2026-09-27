import 'package:flutter/material.dart';
import '../services/announcement_service.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final String classId;

  const CreateAnnouncementScreen({
    super.key,
    required this.classId,
  });

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends State<CreateAnnouncementScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  bool isLoading = false;

  Future<void> publishAnnouncement() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
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
      print('Publishing announcement to class: ${widget.classId}');
      await AnnouncementService().createAnnouncement(
        classId: widget.classId,
        title: title,
        content: content,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement published'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to publish announcement: $e'),
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
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('New Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Announcement',
                hintText: 'Write your announcement here...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : publishAnnouncement,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Publish Announcement'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}