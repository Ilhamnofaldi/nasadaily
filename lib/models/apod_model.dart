import 'package:intl/intl.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../core/app_exceptions.dart';

/// Model untuk data Astronomy Picture of the Day (APOD)
class ApodModel {
  final String date;
  final String title;
  final String explanation;
  final String url;
  final String mediaType;
  final String? hdurl;
  final String? copyright;
  final String? thumbnailUrl;
  final String? serviceVersion;

  const ApodModel({
    required this.date,
    required this.title,
    required this.explanation,
    required this.url,
    required this.mediaType,
    this.hdurl,
    this.copyright,
    this.thumbnailUrl,
    this.serviceVersion,
  });

  factory ApodModel.fromJson(Map<String, dynamic> json) {
    try {
      // Validasi field yang wajib ada
      final title = json['title'] as String?;
      final explanation = json['explanation'] as String?;
      final url = json['url'] as String?;
      final mediaType = json['media_type'] as String?;
      final date = json['date'] as String?;
      
      if (title == null || title.isEmpty) {
        throw ValidationException.emptyField('Title');
      }
      
      if (explanation == null || explanation.isEmpty) {
        throw ValidationException.emptyField('Explanation');
      }
      
      if (url == null || !Validators.isValidUrl(url)) {
        throw ValidationException.invalidUrl(url ?? '');
      }
      
      if (mediaType == null || mediaType.isEmpty) {
        throw ValidationException.emptyField('Media type');
      }
      
      if (date == null || !Validators.isValidDate(date)) {
        throw ValidationException.invalidDate(date ?? '');
      }
      
      // Validasi URL HD jika ada
      final hdurl = json['hdurl'] as String?;
      if (hdurl != null && hdurl.isNotEmpty && !Validators.isValidUrl(hdurl)) {
        throw ValidationException.invalidUrl(hdurl);
      }
      
      return ApodModel(
        date: date.trim(),
        title: title.trim(),
        explanation: explanation.trim(),
        url: url.trim(),
        mediaType: mediaType.toLowerCase().trim(),
        hdurl: hdurl?.trim(),
        copyright: (json['copyright'] as String?)?.trim(),
        thumbnailUrl: (json['thumbnail_url'] as String?)?.trim(),
        serviceVersion: (json['service_version'] as String?)?.trim(),
      );
    } catch (e) {
      if (e is ValidationException) {
        rethrow;
      }
      // Fallback ke parsing sederhana jika validasi gagal
      final fallbackUrl = json['url'] as String? ?? '';
      final fallbackHdurl = json['hdurl'] as String?;
      
      // Skip items with invalid URLs in fallback mode
      if (fallbackUrl.isEmpty || !Validators.isValidUrl(fallbackUrl)) {
        throw ValidationException.invalidUrl(fallbackUrl);
      }
      
      return ApodModel(
        date: json['date'] ?? '',
        title: json['title'] ?? '',
        explanation: json['explanation'] ?? '',
        url: fallbackUrl,
        mediaType: json['media_type'] ?? 'image',
        hdurl: (fallbackHdurl != null && fallbackHdurl.isNotEmpty && Validators.isValidUrl(fallbackHdurl)) ? fallbackHdurl : null,
        copyright: json['copyright'],
        thumbnailUrl: json['thumbnail_url'],
        serviceVersion: json['service_version'],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'title': title,
      'explanation': explanation,
      'url': url,
      'media_type': mediaType,
      if (hdurl != null) 'hdurl': hdurl,
      if (copyright != null) 'copyright': copyright,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (serviceVersion != null) 'service_version': serviceVersion,
    };
  }
  
  /// Factory constructor untuk membuat instance kosong
  factory ApodModel.empty() {
    return ApodModel(
      title: '',
      explanation: '',
      url: '',
      mediaType: 'image',
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  }
  
  /// Copy with method untuk membuat instance baru dengan perubahan
  ApodModel copyWith({
    String? title,
    String? explanation,
    String? url,
    String? hdurl,
    String? mediaType,
    String? date,
    String? copyright,
    String? serviceVersion,
    String? thumbnailUrl,
  }) {
    return ApodModel(
      title: title ?? this.title,
      explanation: explanation ?? this.explanation,
      url: url ?? this.url,
      hdurl: hdurl ?? this.hdurl,
      mediaType: mediaType ?? this.mediaType,
      date: date ?? this.date,
      copyright: copyright ?? this.copyright,
      serviceVersion: serviceVersion ?? this.serviceVersion,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
  
  /// Getter untuk mendapatkan DateTime dari string date
  DateTime get dateTime {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }
  
  /// Getter untuk mendapatkan formatted date
  String get formattedDate => Formatters.formatDisplayDate(dateTime);
  
  /// Getter untuk mendapatkan short formatted date
  String get shortFormattedDate => Formatters.formatShortDate(dateTime);
  
  /// Getter untuk mendapatkan relative date
  String get relativeDate => Formatters.formatRelativeDate(dateTime);
  
  /// Getter untuk mengecek apakah media adalah video
  bool get isVideo => mediaType.toLowerCase() == 'video';
  
  /// Getter untuk mengecek apakah media adalah gambar
  bool get isImage => mediaType.toLowerCase() == 'image';
  
  String get displayUrl {
    if (mediaType == 'video') {
      // If it's a video, prioritize thumbnail_url.
      // If thumbnail_url is null, return an empty string to indicate no valid preview image.
      return thumbnailUrl ?? ''; 
    }
    // For images, use the standard URL.
    return url;
  }
  
  String get highResUrl {
    if (mediaType == 'image') {
      return hdurl ?? url;
    }
    return url;
  }
  
  /// Getter untuk mendapatkan URL thumbnail
  String get thumbnailDisplayUrl => thumbnailUrl ?? url;
  
  /// Getter untuk mendapatkan copyright info yang diformat
  String? get formattedCopyright {
    if (copyright == null || copyright!.isEmpty) {
      return null;
    }
    return '© $copyright';
  }
  
  /// Getter untuk mendapatkan short explanation (untuk preview)
  String get shortExplanation {
    const maxLength = 150;
    if (explanation.length <= maxLength) {
      return explanation;
    }
    return '${explanation.substring(0, maxLength)}...';
  }
  
  /// Getter untuk mendapatkan short title (untuk card)
  String get shortTitle {
    const maxLength = 50;
    if (title.length <= maxLength) {
      return title;
    }
    return '${title.substring(0, maxLength)}...';
  }
  
  /// Method untuk validasi data
  bool get isValid {
    return title.isNotEmpty &&
           explanation.isNotEmpty &&
           url.isNotEmpty &&
           date.isNotEmpty &&
           mediaType.isNotEmpty;
  }
  
  /// Method untuk mendapatkan hash code unik
  String get uniqueId => '${date}_${title.hashCode}';
  
  /// Method untuk mengecek apakah APOD ini adalah hari ini
  bool get isToday {
    final today = DateTime.now();
    final apodDate = dateTime;
    return today.year == apodDate.year &&
           today.month == apodDate.month &&
           today.day == apodDate.day;
  }
  
  /// Method untuk mengecek apakah APOD ini adalah kemarin
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final apodDate = dateTime;
    return yesterday.year == apodDate.year &&
           yesterday.month == apodDate.month &&
           yesterday.day == apodDate.day;
  }
  
  /// Method untuk mendapatkan tag waktu yang user-friendly
  String get timeTag {
    if (isToday) return 'Hari ini';
    if (isYesterday) return 'Kemarin';
    return relativeDate;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApodModel &&
           other.title == title &&
           other.date == date &&
           other.url == url;
  }
  
  @override
  int get hashCode => Object.hash(title, date, url);
  
  @override
  String toString() {
    return 'ApodModel(title: $title, date: $date, mediaType: $mediaType, url: $url)';
  }
}

/// Model untuk response API yang berisi list APOD
class ApodListResponse {
  final List<ApodModel> apods;
  final int total;
  final String? nextDate;
  final String? previousDate;
  final bool hasMore;
  
  const ApodListResponse({
    required this.apods,
    required this.total,
    this.nextDate,
    this.previousDate,
    this.hasMore = false,
  });
  
  factory ApodListResponse.fromJson(List<dynamic> jsonList) {
    try {
      final apods = jsonList
          .map((json) => ApodModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Sort by date descending (newest first)
      apods.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      
      return ApodListResponse(
        apods: apods,
        total: apods.length,
        hasMore: apods.length >= 10, // Assume has more if we got full page
      );
    } catch (e) {
      return ApodListResponse.empty();
    }
  }
  
  factory ApodListResponse.empty() {
    return const ApodListResponse(
      apods: [],
      total: 0,
      hasMore: false,
    );
  }
  
  /// Method untuk mendapatkan APOD berdasarkan tanggal
  ApodModel? getByDate(String date) {
    try {
      return apods.firstWhere((apod) => apod.date == date);
    } catch (e) {
      return null;
    }
  }
  
  /// Method untuk mendapatkan APOD hari ini
  ApodModel? get todayApod {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return getByDate(today);
  }
  
  /// Method untuk mendapatkan APOD terbaru
  ApodModel? get latestApod {
    if (apods.isEmpty) return null;
    return apods.first;
  }
  
  /// Method untuk filter berdasarkan media type
  List<ApodModel> filterByMediaType(String mediaType) {
    return apods.where((apod) => apod.mediaType == mediaType).toList();
  }
  
  /// Method untuk mendapatkan hanya gambar
  List<ApodModel> get imagesOnly => filterByMediaType('image');
  
  /// Method untuk mendapatkan hanya video
  List<ApodModel> get videosOnly => filterByMediaType('video');
  
  /// Method untuk search berdasarkan title atau explanation
  List<ApodModel> search(String query) {
    if (query.isEmpty) return apods;
    
    final lowercaseQuery = query.toLowerCase();
    return apods.where((apod) {
      return apod.title.toLowerCase().contains(lowercaseQuery) ||
             apod.explanation.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  
  /// Method untuk mendapatkan APOD dalam rentang tanggal
  List<ApodModel> getDateRange(DateTime startDate, DateTime endDate) {
    return apods.where((apod) {
      final apodDate = apod.dateTime;
      return apodDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             apodDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  @override
  String toString() {
    return 'ApodListResponse(total: $total, hasMore: $hasMore, apods: ${apods.length})';
  }
}

/// Model untuk favorite APOD
class FavoriteApod {
  final String id;
  final String title;
  final String date;
  final String url;
  final String mediaType;
  final DateTime addedAt;
  
  const FavoriteApod({
    required this.id,
    required this.title,
    required this.date,
    required this.url,
    required this.mediaType,
    required this.addedAt,
  });
  
  factory FavoriteApod.fromApod(ApodModel apod) {
    return FavoriteApod(
      id: apod.uniqueId,
      title: apod.title,
      date: apod.date,
      url: apod.url,
      mediaType: apod.mediaType,
      addedAt: DateTime.now(),
    );
  }
  
  factory FavoriteApod.fromJson(Map<String, dynamic> json) {
    return FavoriteApod(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      url: json['url'] as String,
      mediaType: json['media_type'] as String,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'url': url,
      'media_type': mediaType,
      'added_at': addedAt.toIso8601String(),
    };
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteApod && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
