import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? error;

  ApiException(this.message, {this.statusCode, this.error});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

abstract class HttpClient {
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  });

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? fromJson,
  });

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? fromJson,
  });

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  });
}

class HttpClientImpl implements HttpClient {
  static const String _baseUrl = 'http://localhost:3001/api';
  final http.Client _client;

  HttpClientImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'GET',
      endpoint,
      headers: headers,
      fromJson: fromJson,
    );
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'POST',
      endpoint,
      headers: headers,
      body: body,
      fromJson: fromJson,
    );
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'PUT',
      endpoint,
      headers: headers,
      body: body,
      fromJson: fromJson,
    );
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'DELETE',
      endpoint,
      headers: headers,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      };

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(uri, headers: requestHeaders);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: requestHeaders);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      return _handleResponse<T>(response, fromJson);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw NetworkException('Network error: $error');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        T? data;
        if (fromJson != null && responseData['data'] != null) {
          data = fromJson(responseData['data']);
        } else if (responseData['data'] != null) {
          data = responseData['data'] as T;
        }

        return ApiResponse<T>(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Success',
          data: data,
        );
      } else {
        String errorMessage =
            responseData['message'] ??
            (responseData['error'] is Map
                ? responseData['error']['message']
                : null) ??
            (responseData['error'] is String ? responseData['error'] : null) ??
            'An error occurred';

        String? errorString;
        if (responseData['error'] is Map) {
          errorString = json.encode(responseData['error']);
        } else if (responseData['error'] is String) {
          errorString = responseData['error'];
        }

        throw ApiException(
          errorMessage,
          statusCode: response.statusCode,
          error: errorString,
        );
      }
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException('Failed to parse response: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}
