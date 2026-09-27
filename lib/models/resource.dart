class Resource {
  final String fileName;
  final String fileUrl;
  final String uploadedBy;
  final DateTime uploadedAt;

  Resource({
    required this.fileName,
    required this.fileUrl,
    required this.uploadedBy,
    required this.uploadedAt,
  });
}