import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

class DioConfig {
  Dio getClient() {
    Dio dio = Dio();

    // Assign the BrowserHttpClientAdapter
    final adapter = HttpClientAdapter() as BrowserHttpClientAdapter;
    adapter.withCredentials = true;
    dio.httpClientAdapter = adapter;

    return dio;
  }

}
