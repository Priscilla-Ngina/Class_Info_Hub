import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/resource_service.dart';

class UploadResourceScreen extends StatefulWidget {
  final String classId;

  const UploadResourceScreen({
    super.key,
    required this.classId,
  });

  @override
  State<UploadResourceScreen> createState() =>
      _UploadResourceScreenState();
}

class _UploadResourceScreenState
    extends State<UploadResourceScreen> {
  String? selectedFileName;
  Uint8List? selectedFileBytes;

  bool isLoading = false;

  Future<void> choosePdf() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (file == null) {
        return;
      }

      final fileBytes = await file.readAsBytes();

      setState(() {
        selectedFileName = file.name;
        selectedFileBytes = fileBytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not select the PDF: $e',
          ),
        ),
      );
    }
  }

  Future<void> uploadResource() async {
    if (selectedFileName == null || selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a PDF first'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ResourceService().uploadResource(
        classId: widget.classId,
        fileName: selectedFileName!,
        fileBytes: selectedFileBytes!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resource uploaded successfully'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to upload resource: $e',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
        Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Upload Resource'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload a PDF resource',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : choosePdf,
                icon: const Icon(Icons.attach_file),
                label: const Text('Choose PDF'),
              ),
            ),

            const SizedBox(height: 16),

            if (selectedFileName != null)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf,
                  ),
                  title: Text(selectedFileName!),
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                isLoading ? null : uploadResource,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                  'Upload Resource',
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