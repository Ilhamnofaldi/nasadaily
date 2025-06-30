import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/formatters.dart';

/// Model untuk catatan foto NASA
class CatatanModel {
  final String id;
  final String apodDate;
  final String apodTitle;
  final String apodUrl;
  final String catatan;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const CatatanModel({
    required this.id,
    required this.apodDate,
    required this.apodTitle,
    required this.apodUrl,
    required this.catatan,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory CatatanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CatatanModel(
      id: doc.id,
      apodDate: data['apod_date'] ?? '',
      apodTitle: data['apod_title'] ?? '',
      apodUrl: data['apod_url'] ?? '',
      catatan: data['catatan'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['user_id'] ?? '',
    );
  }

  factory CatatanModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return CatatanModel(
      id: json['id'] ?? '',
      apodDate: json['apod_date'] ?? '',
      apodTitle: json['apod_title'] ?? '',
      apodUrl: json['apod_url'] ?? '',
      catatan: json['catatan'] ?? '',
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apod_date': apodDate,
      'apod_title': apodTitle,
      'apod_url': apodUrl,
      'catatan': catatan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'apod_date': apodDate,
      'apod_title': apodTitle,
      'apod_url': apodUrl,
      'catatan': catatan,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'user_id': userId,
    };
  }

  /// Copy with method untuk membuat instance baru dengan perubahan
  CatatanModel copyWith({
    String? id,
    String? apodDate,
    String? apodTitle,
    String? apodUrl,
    String? catatan,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return CatatanModel(
      id: id ?? this.id,
      apodDate: apodDate ?? this.apodDate,
      apodTitle: apodTitle ?? this.apodTitle,
      apodUrl: apodUrl ?? this.apodUrl,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  /// Getter untuk mendapatkan formatted date
  String get formattedCreatedAt => Formatters.formatDisplayDate(createdAt);
  
  /// Getter untuk mendapatkan formatted date untuk APOD
  String get formattedApodDate {
    try {
      final date = DateTime.parse(apodDate);
      return Formatters.formatDisplayDate(date);
    } catch (e) {
      return apodDate;
    }
  }

  /// Getter untuk mendapatkan relative date
  String get relativeDate => Formatters.formatRelativeDate(createdAt);

  /// Getter untuk mendapatkan short catatan untuk preview
  String get shortCatatan {
    const maxLength = 100;
    if (catatan.length <= maxLength) {
      return catatan;
    }
    return '${catatan.substring(0, maxLength)}...';
  }

  /// Getter untuk mendapatkan short title untuk preview
  String get shortTitle {
    const maxLength = 40;
    if (apodTitle.length <= maxLength) {
      return apodTitle;
    }
    return '${apodTitle.substring(0, maxLength)}...';
  }

  /// Method untuk validasi data
  bool get isValid {
    return apodDate.isNotEmpty &&
           apodTitle.isNotEmpty &&
           apodUrl.isNotEmpty &&
           catatan.isNotEmpty &&
           userId.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CatatanModel &&
           other.id == id &&
           other.apodDate == apodDate &&
           other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(id, apodDate, userId);

  @override
  String toString() {
    return 'CatatanModel(id: $id, apodDate: $apodDate, apodTitle: $apodTitle, catatan: ${catatan.length} chars)';
  }
} 