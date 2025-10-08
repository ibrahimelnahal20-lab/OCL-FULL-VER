// ignore_for_file: file_names, unused_element

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart'; // ستحتاجه للـ Colors في Get.snackbar
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// 1. تم تحديث قائمة نقاط النهاية بالكامل
class EndPoints {
  // Endpoints القديمة
  static const String users = 'Users';
  static const String package = 'Packages';
  static const String task = 'Tasks';
  static const String subTasks = 'SubTasks';

  // === Endpoints الجديدة ===
  static const String login = 'auth/login';
  static const String register = 'auth/';
  static const String checkIn = 'attendance/check-in';
  static const String checkOut = 'attendance/check-out';
  static const String attendanceHistory = 'attendance';

  // === Chat Endpoints ===
  static const String chatSend = 'chat/send';
  static const String chatConversation = 'chat/conversation';
  static const String chatLastMessages = 'chat/last-messages';
  static const String chatDelete = 'chat';
}

class API {
  // 2. تم استخدام الرابط الصحيح
  static const String _baseUrl =
      'http://ahmedlogicpro-001-site5.qtempurl.com/api/';

  static final dio.Dio _dio = dio.Dio(
    dio.BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  // 3. تم تعديل الـ Interceptor ليضيف التوكن تلقائياً
  static void init() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          final box = GetStorage();
          final token = box.read<String>('token');

          // Removed debug prints for security
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Removed debug prints for security
          return handler.next(response);
        },
        onError: (error, handler) {
          _handleError(error);
          return handler.next(error);
        },
      ),
    );
  }

  static Future<dio.Response> getData(
    String endpoint, {
    dio.Options? options,
  }) async {
    try {
      return await _dio.get(endpoint, options: options);
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> postData(
    String endpoint,
    dynamic data, {
    dio.Options? options,
  }) async {
    try {
      return await _dio.post(endpoint, data: data, options: options);
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 4. تم تغيير اسم الدالة هنا إلى putData
  static Future<dio.Response> putData(
    String endpoint,
    dynamic data, {
    dio.Options? options,
  }) async {
    try {
      return await _dio.put(endpoint, data: data, options: options);
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> deleteData(
    String endpoint, {
    dio.Options? options,
  }) async {
    try {
      return await _dio.delete(endpoint, options: options);
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // باقي الدوال تبقى كما هي
  static Future<dio.Response> patchData(
    String endpoint,
    List<Map<String, dynamic>> patchBody,
  ) async {
    try {
      return await _dio.patch(
        endpoint,
        data: patchBody,
        options: dio.Options(
          headers: {"Content-Type": "application/json-patch+json"},
        ),
      );
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> patchImageWeb(
    String endpoint,
    dio.MultipartFile imageFile,
  ) async {
    try {
      return await _dio.patch(
        endpoint,
        data: dio.FormData.fromMap({"ImageFile": imageFile}),
        options: dio.Options(headers: {"Content-Type": "multipart/form-data"}),
      );
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static void _handleError(dio.DioException error) {
    String message = '❌ An unexpected error occurred';
    if (error.response != null) {
      // Removed debug prints for security
      if (error.response?.data is Map<String, dynamic> &&
          error.response!.data.containsKey('message')) {
        message = error.response!.data['message'];
      } else {
        message = "Request failed with status: ${error.response!.statusCode}";
      }
    } else {
      // Removed debug prints for security
      message = "Connection problem. Please check your network.";
    }

    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
