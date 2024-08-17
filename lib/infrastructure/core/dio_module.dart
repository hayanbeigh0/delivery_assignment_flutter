import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shopping_app/config/config.dart';
import 'package:shopping_app/infrastructure/core/auth_interceptor.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        // baseUrl: 'http://192.168.1.5:8000/api/v1',
      ),
    );

    dio.interceptors.add(authInterceptor);

    return dio;
  }
}
