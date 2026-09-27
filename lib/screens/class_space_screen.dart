import 'package:flutter/material.dart';
import '../services/announcement_service.dart';
import '../services/timetable_service.dart';
import '../services/resource_service.dart';
import 'create_announcement_screen.dart';
import 'add_timetable_screen.dart';
import 'upload_resource_screen.dart';

class ClassSpaceScreen extends StatefulWidget {
  final String classId;
  final String programme;
  final String year;
  final bool isManager;

  const ClassSpaceScreen({
    super.key,
    required this.classId,
    required this.programme,
    required this.year,
    this.isManager = false,
  });

  @override
  State<ClassSpaceScreen> createState() => _ClassSpaceScreenState();
}

class _ClassSpaceScreenState extends State<ClassSpaceScreen>
    with SingleTickerProviderStateMixin {
  final AnnouncementService announcementService =
  AnnouncementService();

  final TimetableService timetableService =
  TimetableService();

  final ResourceService resourceService =
  ResourceService();

  List<Map<String, dynamic>> announcements = [];
  List<Map<String, dynamic>> timetableEntries = [];
  List<Map<String, dynamic>> resources = [];

  bool isLoadingAnnouncements = true;
  bool isLoadingTimetable = true;
  bool isLoadingResources = true;

  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 3,
      vsync: this,
    );

    loadAnnouncements();
    loadTimetable();
    loadResources();
  }

  Future<void> loadAnnouncements() async {
    try {
      final results =
      await announcementService.getAnnouncements(widget.classId);

      final List<Map<String, dynamic>> loadedAnnouncements = [];

      for (final document in results.docs) {
        final data =
        document.data() as Map<String, dynamic>;

        loadedAnnouncements.add(data);
      }

      if (mounted) {
        setState(() {
          announcements = loadedAnnouncements;
          isLoadingAnnouncements = false;
        });
      }
    } catch (e) {
      print('Error loading announcements: $e');

      if (mounted) {
        setState(() {
          isLoadingAnnouncements = false;
        });
      }
    }
  }

  Future<void> loadTimetable() async {
    try {
      final results =
      await timetableService.getTimetable(widget.classId);

      final List<Map<String, dynamic>> loadedTimetable = [];

      for (final document in results.docs) {
        final data =
        document.data() as Map<String, dynamic>;

        loadedTimetable.add(data);
      }

      if (mounted) {
        setState(() {
          timetableEntries = loadedTimetable;
          isLoadingTimetable = false;
        });
      }
    } catch (e) {
      print('Error loading timetable: $e');

      if (mounted) {
        setState(() {
          isLoadingTimetable = false;
        });
      }
    }
  }

  Future<void> loadResources() async {
    try {
      final results =
      await resourceService.getResources(widget.classId);

      final List<Map<String, dynamic>> loadedResources = [];

      for (final document in results.docs) {
        final data =
        document.data() as Map<String, dynamic>;

        loadedResources.add(data);
      }

      if (mounted) {
        setState(() {
          resources = loadedResources;
          isLoadingResources = false;
        });
      }
    } catch (e) {
      print('Error loading resources: $e');

      if (mounted) {
        setState(() {
          isLoadingResources = false;
        });
      }
    }
  }

  String formatDateTime(dynamic timestamp) {
    if (timestamp == null) {
      return 'Just now';
    }

    final dateTime = timestamp.toDate();

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;

    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour;

    final minute =
    dateTime.minute.toString().padLeft(2, '0');

    final period =
    dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year, $hour:$minute $period';
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
        Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Class Space'),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.campaign),
              text: 'Announcements',
            ),
            Tab(
              icon: Icon(Icons.calendar_month),
              text: 'Timetable',
            ),
            Tab(
              icon: Icon(Icons.folder),
              text: 'Resources',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          buildAnnouncementsSection(),
          buildTimetableSection(),
          buildResourcesSection(),
        ],
      ),
    );
  }

  Widget buildAnnouncementsSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            widget.programme,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Year ${widget.year}',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Announcements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.isManager)
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'New announcement',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateAnnouncementScreen(
                              classId: widget.classId,
                            ),
                      ),
                    ).then((_) {
                      loadAnnouncements();
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoadingAnnouncements
                ? const Center(
              child:
              CircularProgressIndicator(),
            )
                : announcements.isEmpty
                ? const Center(
              child: Text(
                'No announcements yet.',
                textAlign:
                TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount:
              announcements.length,
              itemBuilder:
                  (context, index) {
                final announcement =
                announcements[index];

                return Card(
                  margin:
                  const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Padding(
                    padding:
                    const EdgeInsets.all(
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          announcement['title'],
                          style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                            height: 8),
                        Text(
                          announcement[
                          'content'],
                          style:
                          const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                            height: 8),
                        Text(
                          'Posted: ${formatDateTime(announcement['postedAt'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                            Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimetableSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            widget.programme,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Year ${widget.year}',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Timetable',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.isManager)
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip:
                  'Add timetable entry',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddTimetableScreen(
                              classId: widget.classId,
                            ),
                      ),
                    ).then((_) {
                      loadTimetable();
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoadingTimetable
                ? const Center(
              child:
              CircularProgressIndicator(),
            )
                : timetableEntries.isEmpty
                ? const Center(
              child: Text(
                'No timetable entries yet.',
                textAlign:
                TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount:
              timetableEntries.length,
              itemBuilder:
                  (context, index) {
                final entry =
                timetableEntries[index];

                return Card(
                  margin:
                  const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ListTile(
                    leading:
                    const Icon(
                      Icons.calendar_today,
                    ),
                    title: Text(
                      entry['unit'],
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${entry['day']} • ${entry['time']}\n'
                          'Room: ${entry['room']}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResourcesSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            widget.programme,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Year ${widget.year}',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resources',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.isManager)
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Upload resource',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UploadResourceScreen(
                              classId: widget.classId,
                            ),
                      ),
                    ).then((_) {
                      loadResources();
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoadingResources
                ? const Center(
              child:
              CircularProgressIndicator(),
            )
                : resources.isEmpty
                ? const Center(
              child: Text(
                'No resources uploaded yet.',
                textAlign:
                TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount: resources.length,
              itemBuilder:
                  (context, index) {
                final resource =
                resources[index];

                return Card(
                  margin:
                  const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ListTile(
                    leading:
                    const Icon(
                      Icons.picture_as_pdf,
                    ),
                    title: Text(
                      resource['fileName'],
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'Uploaded: ${formatDateTime(resource['uploadedAt'])}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}