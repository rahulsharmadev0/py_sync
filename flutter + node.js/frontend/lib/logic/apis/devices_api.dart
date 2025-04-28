import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';

class DevicesApi {
  final String baseUrl;

  const DevicesApi({required this.baseUrl});

  Future<List<Device>> getAllDevices(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pisync/devices'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['devices'] as List).map((device) => Device.fromJson(device)).toList();
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
