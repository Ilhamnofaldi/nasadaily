/// Custom exception classes for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });
  
  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'No internet connection available',
      code: 'NO_CONNECTION',
    );
  }
  
  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Request timeout. Please try again.',
      code: 'TIMEOUT',
    );
  }
  
  factory NetworkException.serverError(int statusCode) {
    return NetworkException(
      message: 'Server error occurred (Status: $statusCode)',
      code: 'SERVER_ERROR_$statusCode',
    );
  }
  
  factory NetworkException.rateLimited() {
    return const NetworkException(
      message: 'Rate limit exceeded. Please try again later.',
      code: 'RATE_LIMITED',
    );
  }
}

/// API related exceptions
class ApiException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? responseData;
  
  const ApiException({
    required String message,
    String? code,
    this.statusCode,
    this.responseData,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  factory ApiException.invalidApiKey() {
    return const ApiException(
      message: 'Invalid API key. Please check your configuration.',
      code: 'INVALID_API_KEY',
      statusCode: 403,
    );
  }
  
  factory ApiException.notFound() {
    return const ApiException(
      message: 'Requested resource not found.',
      code: 'NOT_FOUND',
      statusCode: 404,
    );
  }
  
  factory ApiException.badRequest(String details) {
    return ApiException(
      message: 'Bad request: $details',
      code: 'BAD_REQUEST',
      statusCode: 400,
    );
  }
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  factory CacheException.readError() {
    return const CacheException(
      message: 'Failed to read from cache',
      code: 'CACHE_READ_ERROR',
    );
  }
  
  factory CacheException.writeError() {
    return const CacheException(
      message: 'Failed to write to cache',
      code: 'CACHE_WRITE_ERROR',
    );
  }
  
  factory CacheException.corruptedData() {
    return const CacheException(
      message: 'Cached data is corrupted',
      code: 'CACHE_CORRUPTED',
    );
  }
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  
  const ValidationException({
    required String message,
    String? code,
    this.fieldErrors,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  factory ValidationException.invalidDate(String date) {
    return ValidationException(
      message: 'Invalid date format: $date',
      code: 'INVALID_DATE',
      fieldErrors: {'date': 'Please use YYYY-MM-DD format'},
    );
  }
  
  factory ValidationException.invalidUrl(String url) {
    return ValidationException(
      message: 'Invalid URL: $url',
      code: 'INVALID_URL',
      fieldErrors: {'url': 'Please provide a valid URL'},
    );
  }
  
  factory ValidationException.emptyField(String fieldName) {
    return ValidationException(
      message: '$fieldName cannot be empty',
      code: 'EMPTY_FIELD',
      fieldErrors: {fieldName.toLowerCase(): 'This field is required'},
    );
  }
}

/// Storage related exceptions
class StorageException extends AppException {
  const StorageException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  factory StorageException.insufficientSpace() {
    return const StorageException(
      message: 'Insufficient storage space',
      code: 'INSUFFICIENT_SPACE',
    );
  }
  
  factory StorageException.permissionDenied() {
    return const StorageException(
      message: 'Storage permission denied',
      code: 'PERMISSION_DENIED',
    );
  }
  
  factory StorageException.fileNotFound(String fileName) {
    return StorageException(
      message: 'File not found: $fileName',
      code: 'FILE_NOT_FOUND',
    );
  }
}

/// Image loading related exceptions
class ImageException extends AppException {
  const ImageException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  factory ImageException.loadFailed(String url) {
    return ImageException(
      message: 'Failed to load image from: $url',
      code: 'IMAGE_LOAD_FAILED',
    );
  }
  
  factory ImageException.invalidFormat() {
    return const ImageException(
      message: 'Invalid image format',
      code: 'INVALID_FORMAT',
    );
  }
  
  factory ImageException.tooLarge(int sizeInBytes) {
    return ImageException(
      message: 'Image too large: ${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
      code: 'IMAGE_TOO_LARGE',
    );
  }
}

/// Video related exceptions
class VideoException extends AppException {
  const VideoException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  factory VideoException.playbackFailed(String url) {
    return VideoException(
      message: 'Failed to play video from: $url',
      code: 'VIDEO_PLAYBACK_FAILED',
    );
  }
  
  factory VideoException.unsupportedFormat() {
    return const VideoException(
      message: 'Unsupported video format',
      code: 'UNSUPPORTED_FORMAT',
    );
  }
  
  factory VideoException.streamingError() {
    return const VideoException(
      message: 'Video streaming error',
      code: 'STREAMING_ERROR',
    );
  }
}

/// Unknown or unexpected exceptions
class UnknownException extends AppException {
  const UnknownException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  factory UnknownException.fromError(dynamic error, [StackTrace? stackTrace]) {
    return UnknownException(
      message: 'An unexpected error occurred: ${error.toString()}',
      code: 'UNKNOWN_ERROR',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}