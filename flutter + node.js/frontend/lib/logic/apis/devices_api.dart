import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';

class DevicesApi {
  final String baseUrl;

  const DevicesApi({required this.baseUrl});

  Future<Map<String, dynamic>> getAllDevices(
    String token, {
    int page = 1,
    int limit = 10,
    String? syncStatusCode,
    String? sortBy,
    String? order,
  }) async {
    // Build query parameters
    final queryParams = <String, String>{};
    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    if (syncStatusCode != null) {
      queryParams['sync_status_code'] = syncStatusCode;
    }

    if (sortBy != null) {
      queryParams['sort_by'] = sortBy;
    }

    if (order != null) {
      queryParams['order'] = order;
    }

    final uri = Uri.parse(
      '$baseUrl/pisync/devices',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Device> syncDevice(String token, String deviceId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pisync/devices/$deviceId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Device.fromJson(jsonDecode(response.body)['device']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
