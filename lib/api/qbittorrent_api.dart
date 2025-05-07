import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class QBittorrentAPI extends ChangeNotifier {
  String? baseUrl;
  String? _sid;

  QBittorrentAPI({this.baseUrl});

  void setBaseUrl(String url) {
    baseUrl = url;
    _sid = null; // Clear session when URL changes
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    if (baseUrl == null) throw Exception('Server URL not set');
    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/auth/login'),
      body: {
        'username': username,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      _sid = response.headers['set-cookie']?.split(';')[0].split('=')[1];
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<List<dynamic>> getTorrents() async {
    if (baseUrl == null) throw Exception('Server URL not set');
    if (_sid == null) throw Exception('Not logged in');
    final response = await http.get(
      Uri.parse('$baseUrl/api/v2/torrents/info'),
      headers: {'Cookie': 'SID=$_sid'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load torrents');
  }

  Future<bool> addTorrent(String url) async {
    if (baseUrl == null) throw Exception('Server URL not set');
    if (_sid == null) throw Exception('Not logged in');
    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/torrents/add'),
      headers: {'Cookie': 'SID=$_sid'},
      body: {'urls': url},
    );
    return response.statusCode == 200;
  }

  Future<bool> pauseTorrent(String hash) async {
    if (baseUrl == null) throw Exception('Server URL not set');
    if (_sid == null) throw Exception('Not logged in');
    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/torrents/pause'),
      headers: {'Cookie': 'SID=$_sid'},
      body: {'hashes': hash},
    );
    return response.statusCode == 200;
  }

  Future<bool> resumeTorrent(String hash) async {
    if (baseUrl == null) throw Exception('Server URL not set');
    if (_sid == null) throw Exception('Not logged in');
    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/torrents/resume'),
      headers: {'Cookie': 'SID=$_sid'},
      body: {'hashes': hash},
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteTorrent(String hash) async {
    if (baseUrl == null) throw Exception('Server URL not set');
    if (_sid == null) throw Exception('Not logged in');
    final response = await http.post(
      Uri.parse('$baseUrl/api/v2/torrents/delete'),
      headers: {'Cookie': 'SID=$_sid'},
      body: {'hashes': hash},
    );
    return response.statusCode == 200;
  }
} 