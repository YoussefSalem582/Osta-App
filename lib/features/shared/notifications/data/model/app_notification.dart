import 'package:equatable/equatable.dart';

/// A single notification feed item (mirrors backend `NotificationResource`).
/// PHP serializes an empty `data` array as `[]`, so `fromJson` guards the
/// non-map case.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    this.title,
    this.body,
    this.data = const {},
    this.readAt,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id']?.toString() ?? '',
        type: json['type'] as String? ?? '',
        title: json['title'] as String?,
        body: json['body'] as String?,
        // Empty payloads arrive as `[]`; only a real object is a map.
        data: json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : const {},
        readAt: _date(json['read_at']),
        createdAt: _date(json['created_at']),
      );

  final String id;
  final String type;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isRead => readAt != null;

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.tryParse(v) : null;

  @override
  List<Object?> get props => [id, type, title, body, data, readAt, createdAt];
}
