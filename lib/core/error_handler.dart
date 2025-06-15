import 'dart:io';
import 'package:flutter/foundation.dart';
import 'app_exceptions.dart';
import '../utils/app_logger.dart';

/// Centralized error handler for the application
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Handle and convert various errors to AppException
  AppException handleError(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('Error occurred', 'ErrorHandler', error, stackTrace);

    if (error is AppException) {
      return error;
    }

    // Network errors
    if (error is SocketException) {
      return NetworkException.noConnection();
    }

    if (error is HttpException) {
      return NetworkException.serverError(error.message.contains('404') ? 404 : 500);
    }

    // Timeout errors
    if (error.toString().toLowerCase().contains('timeout')) {
      return NetworkException.timeout();
    }

    // Format errors
    if (error is FormatException) {
      return ValidationException(
        message: 'Invalid data format: ${error.message}',
        code: 'FORMAT_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Type errors
    if (error is TypeError) {
      return ValidationException(
        message: 'Type error occurred',
        code: 'TYPE_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Argument errors
    if (error is ArgumentError) {
      return ValidationException(
        message: 'Invalid argument: ${error.message}',
        code: 'ARGUMENT_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Range errors
    if (error is RangeError) {
      return ValidationException(
        message: 'Range error: ${error.message}',
        code: 'RANGE_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // State errors
    if (error is StateError) {
      return ValidationException(
        message: 'State error: ${error.message}',
        code: 'STATE_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Unsupported errors
    if (error is UnsupportedError) {
      return ValidationException(
        message: 'Unsupported operation: ${error.message}',
        code: 'UNSUPPORTED_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Default to unknown exception
    return UnknownException.fromError(error, stackTrace);
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        final networkEx = exception as NetworkException;
        switch (networkEx.code) {
          case 'NO_CONNECTION':
            return 'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.';
          case 'TIMEOUT':
            return 'Koneksi timeout. Silakan coba lagi.';
          case 'RATE_LIMITED':
            return 'Terlalu banyak permintaan. Tunggu sebentar dan coba lagi.';
          default:
            if (networkEx.code?.startsWith('SERVER_ERROR') == true) {
              return 'Terjadi masalah pada server. Silakan coba lagi nanti.';
            }
            return 'Terjadi masalah jaringan. Silakan coba lagi.';
        }

      case ApiException:
        final apiEx = exception as ApiException;
        switch (apiEx.code) {
          case 'INVALID_API_KEY':
            return 'Konfigurasi API tidak valid. Silakan hubungi administrator.';
          case 'NOT_FOUND':
            return 'Data yang diminta tidak ditemukan.';
          case 'BAD_REQUEST':
            return 'Permintaan tidak valid. Silakan periksa input Anda.';
          default:
            return 'Terjadi masalah dengan layanan. Silakan coba lagi.';
        }

      case CacheException:
        return 'Terjadi masalah dengan penyimpanan data. Aplikasi akan memuat ulang data.';

      case ValidationException:
        final validationEx = exception as ValidationException;
        if (validationEx.fieldErrors?.isNotEmpty == true) {
          return validationEx.fieldErrors!.values.first;
        }
        return exception.message;

      case StorageException:
        final storageEx = exception as StorageException;
        switch (storageEx.code) {
          case 'INSUFFICIENT_SPACE':
            return 'Ruang penyimpanan tidak cukup. Hapus beberapa file dan coba lagi.';
          case 'PERMISSION_DENIED':
            return 'Izin akses penyimpanan ditolak. Periksa pengaturan aplikasi.';
          case 'FILE_NOT_FOUND':
            return 'File tidak ditemukan.';
          default:
            return 'Terjadi masalah dengan penyimpanan.';
        }

      case ImageException:
        final imageEx = exception as ImageException;
        switch (imageEx.code) {
          case 'IMAGE_LOAD_FAILED':
            return 'Gagal memuat gambar. Periksa koneksi internet Anda.';
          case 'INVALID_FORMAT':
            return 'Format gambar tidak didukung.';
          case 'IMAGE_TOO_LARGE':
            return 'Ukuran gambar terlalu besar.';
          default:
            return 'Terjadi masalah dengan gambar.';
        }

      case VideoException:
        final videoEx = exception as VideoException;
        switch (videoEx.code) {
          case 'VIDEO_PLAYBACK_FAILED':
            return 'Gagal memutar video. Periksa koneksi internet Anda.';
          case 'UNSUPPORTED_FORMAT':
            return 'Format video tidak didukung.';
          case 'STREAMING_ERROR':
            return 'Terjadi masalah saat streaming video.';
          default:
            return 'Terjadi masalah dengan video.';
        }

      default:
        return 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';
    }
  }

  /// Log error with appropriate level
  void logError(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
      case ApiException:
        AppLogger.warning('API/Network Error: ${exception.message}', 
          'ErrorHandler');
        break;
      case ValidationException:
        AppLogger.info('Validation Error: ${exception.message}');
        break;
      case CacheException:
      case StorageException:
        AppLogger.warning('Storage Error: ${exception.message}', 
          'ErrorHandler');
        break;
      case ImageException:
      case VideoException:
        AppLogger.warning('Media Error: ${exception.message}', 
          'ErrorHandler');
        break;
      default:
        AppLogger.error('Unknown Error: ${exception.message}', 
          'ErrorHandler', exception.originalError, exception.stackTrace);
    }
  }

  /// Check if error is recoverable
  bool isRecoverable(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        final networkEx = exception as NetworkException;
        return networkEx.code != 'NO_CONNECTION';
      case ApiException:
        final apiEx = exception as ApiException;
        return apiEx.statusCode != 403 && apiEx.statusCode != 401;
      case CacheException:
      case StorageException:
        return true;
      case ValidationException:
        return true;
      case ImageException:
      case VideoException:
        return true;
      default:
        return false;
    }
  }

  /// Get retry delay for recoverable errors
  Duration getRetryDelay(AppException exception, int retryCount) {
    if (!isRecoverable(exception)) {
      return Duration.zero;
    }

    // Exponential backoff with jitter
    final baseDelay = Duration(seconds: 2);
    final exponentialDelay = Duration(
      milliseconds: (baseDelay.inMilliseconds * (1 << retryCount)).clamp(0, 30000)
    );
    
    // Add jitter (±25%)
    final jitter = (exponentialDelay.inMilliseconds * 0.25).round();
    final jitterMs = (exponentialDelay.inMilliseconds + 
      (DateTime.now().millisecondsSinceEpoch % (jitter * 2)) - jitter)
      .clamp(1000, 30000);
    
    return Duration(milliseconds: jitterMs);
  }

  /// Handle error and return appropriate action
  ErrorAction getErrorAction(AppException exception) {
    if (exception is NetworkException) {
      switch (exception.code) {
        case 'NO_CONNECTION':
          return ErrorAction.showSnackbar;
        case 'TIMEOUT':
        case 'RATE_LIMITED':
          return ErrorAction.retry;
        default:
          return ErrorAction.showDialog;
      }
    }

    if (exception is ValidationException) {
      return ErrorAction.showInline;
    }

    if (exception is CacheException || exception is StorageException) {
      return ErrorAction.silent;
    }

    return ErrorAction.showDialog;
  }
}

/// Enum for different error handling actions
enum ErrorAction {
  showDialog,
  showSnackbar,
  showInline,
  retry,
  silent,
}

/// Result wrapper for operations that can fail
class Result<T> {
  final T? data;
  final AppException? error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  factory Result.failure(AppException error) {
    return Result._(error: error, isSuccess: false);
  }

  factory Result.fromException(dynamic exception, [StackTrace? stackTrace]) {
    final appException = ErrorHandler().handleError(exception, stackTrace);
    return Result.failure(appException);
  }

  /// Transform success data
  Result<U> map<U>(U Function(T data) transform) {
    if (isSuccess && data != null) {
      try {
        return Result.success(transform(data!));
      } catch (e, stackTrace) {
        return Result.fromException(e, stackTrace);
      }
    }
    return Result.failure(error!);
  }

  /// Transform error
  Result<T> mapError(AppException Function(AppException error) transform) {
    if (!isSuccess && error != null) {
      return Result.failure(transform(error!));
    }
    return this;
  }

  /// Execute function on success
  Result<T> onSuccess(void Function(T data) action) {
    if (isSuccess && data != null) {
      action(data!);
    }
    return this;
  }

  /// Execute function on failure
  Result<T> onFailure(void Function(AppException error) action) {
    if (!isSuccess && error != null) {
      action(error!);
    }
    return this;
  }

  /// Get data or throw exception
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw error!;
  }

  /// Get data or return default value
  T dataOr(T defaultValue) {
    return isSuccess && data != null ? data! : defaultValue;
  }

  @override
  String toString() {
    return isSuccess 
      ? 'Result.success($data)' 
      : 'Result.failure($error)';
  }
}