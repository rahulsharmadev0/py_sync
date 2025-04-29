import 'dart:convert';
import 'package:http/http.dart' as http;

class LogsApi {
  final String baseUrl;

  const LogsApi({required this.baseUrl});

  Future<Map<String, dynamic>> getAllLogs(
    String token, {
    int page = 1,
    int limit = 10,
    String? sortBy = 'last_attempt_at',
    String? order = 'desc',
  }) async {
    // Build query parameters
    final queryParams = <String, String>{};
    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    if (sortBy != null) {
      queryParams['sort_by'] = sortBy;
    }

    if (order != null) {
      queryParams['order'] = order;
    }

    final uri = Uri.parse(
      '$baseUrl/pisync/devices/logs',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
