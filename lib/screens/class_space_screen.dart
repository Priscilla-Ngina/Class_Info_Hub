import 'package:flutter/material.dart';
import '../services/announcement_service.dart';
import '../services/timetable_service.dart';
import '../services/resource_service.dart';
import 'create_announcement_screen.dart';
import 'add_timetable_screen.dart';
import 'upload_resource_screen.dart';
import 'edit_announcement_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // ============================================================
  // ANNOUNCEMENTS
  // ============================================================

  Future<void> loadAnnouncements() async {
    try {
      final results =
      await announcementService.getAnnouncements(widget.classId);

      final List<Map<String, dynamic>> loadedAnnouncements = [];

      for (final document in results.docs) {
        final data =
        document.data() as Map<String, dynamic>;

        loadedAnnouncements.add({
          'id': document.id,
          ...data,
        });
      }

      loadedAnnouncements.sort((a, b) {
        final aPinned = a['isPinned'] == true;
        final bPinned = b['isPinned'] == true;

        if (aPinned && !bPinned) {
          return -1;
        }

        if (!aPinned && bPinned) {
          return 1;
        }

        return 0;
      });

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

  Future<void> togglePin(
      String announcementId,
      bool currentlyPinned,
      ) async {
    try {
      await announcementService.setPinned(
        classId: widget.classId,
        announcementId: announcementId,
        isPinned: !currentlyPinned,
      );

      await loadAnnouncements();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentlyPinned
                ? 'Announcement unpinned'
                : 'Announcement pinned',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update announcement: $e',
          ),
        ),
      );
    }
  }

  Future<void> deleteAnnouncement(
      String announcementId,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete announcement'),
          content: const Text(
            'Are you sure you want to delete this announcement?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await announcementService.deleteAnnouncement(
        classId: widget.classId,
        announcementId: announcementId,
      );

      await loadAnnouncements();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement deleted'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete announcement: $e',
          ),
        ),
      );
    }
  }
  Future<void> editAnnouncement(
      Map<String, dynamic> announcement,
      ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAnnouncementScreen(
          classId: widget.classId,
          announcementId: announcement['id'],
          title: announcement['title'],
          content: announcement['content'],
        ),
      ),
    );

    if (result == true) {
      await loadAnnouncements();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement updated'),
        ),
      );
    }
  }

  // ============================================================
  // TIMETABLE
  // ============================================================

  Future<void> loadTimetable() async {
    try {
      final results =
      await timetableService.getTimetable(widget.classId);

      final List<Map<String, dynamic>> loadedTimetable = [];

      for (final document in results.docs) {
        final data =
        document.data() as Map<String, dynamic>;

        loadedTimetable.add({
          'id': document.id,
          ...data,
        });
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

  Future<void> openResource(String fileUrl) async {
    final uri = Uri.parse(fileUrl);

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open this resource.'),
        ),
      );
    }
  }

  Future<void> editTimetableEntry(
      Map<String, dynamic> entry,
      ) async {
    final dayController = TextEditingController(
      text: entry['day'],
    );

    final unitController = TextEditingController(
      text: entry['unit'],
    );

    final timeController = TextEditingController(
      text: entry['time'],
    );

    final roomController = TextEditingController(
      text: entry['room'],
    );

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit timetable entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: dayController,
                  decoration: const InputDecoration(
                    labelText: 'Day',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final day = dayController.text.trim();
                final unit = unitController.text.trim();
                final time = timeController.text.trim();
                final room = roomController.text.trim();

                if (day.isEmpty ||
                    unit.isEmpty ||
                    time.isEmpty ||
                    room.isEmpty) {
                  return;
                }

                try {
                  await timetableService.updateTimetableEntry(
                    classId: widget.classId,
                    timetableId: entry['id'],
                    day: day,
                    unit: unit,
                    time: time,
                    room: room,
                  );

                  if (!dialogContext.mounted) return;

                  Navigator.of(dialogContext).pop(true);
                } catch (e) {
                  print('Error editing timetable: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true && mounted) {
      await loadTimetable();
    }

    dayController.dispose();
    unitController.dispose();
    timeController.dispose();
    roomController.dispose();
  }

  Future<void> deleteTimetableEntry(
      String timetableId,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete timetable entry'),
          content: const Text(
            'Are you sure you want to delete this timetable entry?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await timetableService.deleteTimetableEntry(
        classId: widget.classId,
        timetableId: timetableId,
      );

      await loadTimetable();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timetable entry deleted'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete timetable entry: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // RESOURCES
  // ============================================================

  Future<void> loadResources() async {
    try {
      final results =
      await resourceService.getResources(widget.classId);

      final List<Map<String, dynamic>> loadedResources = [];

      for (final document in results.docs) {
        final data =
        document.data() as Map<String, dynamic>;

        loadedResources.add({
          'id': document.id,
          ...data,
        });
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

  Future<void> deleteResource(Map<String, dynamic> resource) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Resource?'),
          content: Text(
            'Are you sure you want to delete "${resource['fileName']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await resourceService.deleteResource(
        classId: widget.classId,
        resourceId: resource['id'],
        storagePath: resource['storagePath'],
      );

      await loadResources();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resource deleted'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete resource: $e'),
        ),
      );
    }
  }

  // ============================================================
  // GENERAL HELPERS
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

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

  // ============================================================
  // ANNOUNCEMENTS SECTION
  // ============================================================

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
              child: CircularProgressIndicator(),
            )
                : announcements.isEmpty
                ? const Center(
              child: Text(
                'No announcements yet.',
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount:
              announcements.length,
              itemBuilder:
                  (context, index) {
                final announcement =
                announcements[index];

                final isPinned =
                    announcement['isPinned'] ==
                        true;

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
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Expanded(
                              child: Text(
                                announcement[
                                'title'],
                                style:
                                const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ),
                            if (isPinned)
                              const Padding(
                                padding:
                                EdgeInsets
                                    .only(
                                  left: 8,
                                ),
                                child: Icon(
                                  Icons.push_pin,
                                  size: 20,
                                ),
                              ),
                            if (widget.isManager)
                              PopupMenuButton<
                                  String>(
                                onSelected:
                                    (value) {
                                  if (value ==
                                      'pin') {
                                    togglePin(
                                      announcement[
                                      'id'],
                                      isPinned,
                                    );
                                  }

                                  if (value ==
                                      'edit') {
                                    editAnnouncement(
                                      announcement,
                                    );
                                  }

                                  if (value ==
                                      'delete') {
                                    deleteAnnouncement(
                                      announcement[
                                      'id'],
                                    );
                                  }
                                },
                                itemBuilder:
                                    (context) {
                                  return [
                                    PopupMenuItem(
                                      value:
                                      'pin',
                                      child:
                                      Row(
                                        children: [
                                          Icon(
                                            isPinned
                                                ? Icons
                                                .push_pin_outlined
                                                : Icons
                                                .push_pin,
                                          ),
                                          const SizedBox(
                                            width:
                                            8,
                                          ),
                                          Text(
                                            isPinned
                                                ? 'Unpin'
                                                : 'Pin',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value:
                                      'edit',
                                      child:
                                      Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .edit,
                                          ),
                                          SizedBox(
                                            width:
                                            8,
                                          ),
                                          Text(
                                            'Edit',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value:
                                      'delete',
                                      child:
                                      Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .delete,
                                          ),
                                          SizedBox(
                                            width:
                                            8,
                                          ),
                                          Text(
                                            'Delete',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ];
                                },
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          announcement[
                          'content'],
                          style:
                          const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Posted: ${formatDateTime(announcement['postedAt'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                            Colors.grey[
                            600],
                          ),
                        ),
                        if (isPinned)
                          const Padding(
                            padding:
                            EdgeInsets.only(
                              top: 8,
                            ),
                            child: Text(
                              'Pinned announcement',
                              style:
                              TextStyle(
                                fontSize: 12,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
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

  // ============================================================
  // TIMETABLE SECTION
  // ============================================================

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
                    trailing: widget.isManager
                        ? Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        IconButton(
                          icon:
                          const Icon(
                            Icons.edit,
                          ),
                          tooltip:
                          'Edit timetable entry',
                          onPressed: () {
                            editTimetableEntry(
                              entry,
                            );
                          },
                        ),
                        IconButton(
                          icon:
                          const Icon(
                            Icons.delete,
                          ),
                          tooltip:
                          'Delete timetable entry',
                          onPressed: () {
                            deleteTimetableEntry(
                              entry['id'],
                            );
                          },
                        ),
                      ],
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESOURCES SECTION
  // ============================================================

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
              itemCount:
              resources.length,
              itemBuilder:
                  (context, index) {
                final resource =
                resources[index];
                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.picture_as_pdf,
                    ),
                    title: Text(
                      resource['fileName'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'Uploaded: ${formatDateTime(resource['uploadedAt'])}',
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          tooltip: 'Download resource',
                          onPressed: () {
                            openResource(resource['fileUrl']);
                          },
                        ),

                        if (widget.isManager)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete resource',
                            onPressed: () {
                              deleteResource(resource);
                            },
                          ),
                      ],
                    ),
                    onTap: () {
                      openResource(resource['fileUrl']);
                    },
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