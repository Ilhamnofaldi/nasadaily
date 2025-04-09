class ApodModel {
  final String date;
  final String title;
  final String explanation;
  final String url;
  final String mediaType;
  final String? hdurl;
  final String? copyright;
  final String? thumbnailUrl;

  ApodModel({
    required this.date,
    required this.title,
    required this.explanation,
    required this.url,
    required this.mediaType,
    this.hdurl,
    this.copyright,
    this.thumbnailUrl,
  });

  factory ApodModel.fromJson(Map<String, dynamic> json) {
    return ApodModel(
      date: json['date'] ?? '',
      title: json['title'] ?? '',
      explanation: json['explanation'] ?? '',
      url: json['url'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      hdurl: json['hdurl'],
      copyright: json['copyright'],
      thumbnailUrl: json['thumbnail_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'title': title,
      'explanation': explanation,
      'url': url,
      'media_type': mediaType,
      'hdurl': hdurl,
      'copyright': copyright,
      'thumbnail_url': thumbnailUrl,
    };
  }
  
  String get displayUrl {
    if (mediaType == 'video') {
      return thumbnailUrl ?? url;
    }
    return url;
  }
  
  String get highResUrl {
    if (mediaType == 'image') {
      return hdurl ?? url;
    }
    return url;
  }
}
