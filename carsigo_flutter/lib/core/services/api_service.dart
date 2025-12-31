import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

class ApiService {
  final Dio _dio;
  final Logger _logger = Logger();

  ApiService(String baseUrl) : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: AppConfig.connectionTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    sendTimeout: AppConfig.sendTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor for logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('API Request: ${options.method} ${options.path}');
          _logger.d('Headers: ${options.headers}');
          if (options.data != null) {
            _logger.d('Data: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('API Response: ${response.statusCode} ${response.requestOptions.path}');
          _logger.d('Response data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('API Error: ${error.message}');
          _logger.e('Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  // Set authentication token
  void setAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // GET request
  Future<Response<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response<Map<String, dynamic>>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response<Map<String, dynamic>>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response<Map<String, dynamic>>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file
  Future<Response<Map<String, dynamic>>> upload(
    String path,
    String filePath, {
    String? fieldName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (data != null) ...data,
        fieldName ?? 'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handle Dio errors
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException('Tiempo de conexión agotado', error.type);
      case DioExceptionType.sendTimeout:
        return ApiException('Tiempo de envío agotado', error.type);
      case DioExceptionType.receiveTimeout:
        return ApiException('Tiempo de respuesta agotado', error.type);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Error desconocido';
        
        switch (statusCode) {
          case 400:
            return ApiException('Solicitud inválida: $message', error.type);
          case 401:
            return ApiException('No autorizado: $message', error.type);
          case 403:
            return ApiException('Acceso denegado: $message', error.type);
          case 404:
            return ApiException('Recurso no encontrado: $message', error.type);
          case 422:
            return ApiException('Error de validación: $message', error.type);
          case 500:
            return ApiException('Error del servidor: $message', error.type);
          default:
            return ApiException('Error HTTP $statusCode: $message', error.type);
        }
      case DioExceptionType.cancel:
        return ApiException('Solicitud cancelada', error.type);
      case DioExceptionType.unknown:
        return ApiException('Error de conexión: ${error.message}', error.type);
      default:
        return ApiException('Error desconocido: ${error.message}', error.type);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final DioExceptionType type;

  ApiException(this.message, this.type);

  @override
  String toString() => message;
}
