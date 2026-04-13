import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/store_zone.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio, String baseUrl = 'https://api.merch-mobile.example.com'})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token =
                await FirebaseAuth.instance.currentUser?.getIdToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {
            // Swallow auth errors — request will go out unauthenticated
            // and server will reject if required.
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<List<Product>> getProducts({String? query, String? category}) async {
    final response = await _dio.get<List<dynamic>>(
      '/products',
      queryParameters: {
        if (query != null) 'q': query,
        if (category != null) 'category': category,
      },
    );
    final data = response.data ?? const [];
    return data
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<StoreZone>> syncZones(List<StoreZone> zones) async {
    final response = await _dio.post<List<dynamic>>(
      '/zones/sync',
      data: zones.map((z) => z.toJson()).toList(),
    );
    final data = response.data ?? const [];
    return data
        .map((e) => StoreZone.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
