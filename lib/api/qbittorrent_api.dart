import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class QBittorrentAPI extends ChangeNotifier {
  String? baseUrl;
  String? _sid;

  QBittorrentAPI({this.baseUrl});

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  final log = Logger(
    printer: PrettyPrinter(),
  );

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
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v2/torrents/info'),
        headers: {
          'Cookie': 'SID=$_sid',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Get torrents failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load torrents: ${response.statusCode}');
      }
    } catch (e) {
      print('Get torrents error: $e');
      throw Exception('Failed to load torrents: $e');
    }
  }

  Future<bool> addTorrent(String url) async {
    if (baseUrl == null) throw Exception('Server URL not set');
    if (_sid == null) throw Exception('Not logged in');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v2/torrents/add'),
        headers: {
          'Cookie': 'SID=$_sid',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {'urls': url},
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Add torrent failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Add torrent error: $e');
      throw Exception('Failed to add torrent: $e');
    }
  }

  Future<bool> pauseTorrent(String hash) async {
    if (baseUrl == null) throw Exception('Server URL not set');
    if (_sid == null) throw Exception('Not logged in');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v2/torrents/pause'),
        headers: {
          'Cookie': 'SID=$_sid',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {'hashes': hash},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Pause torrent error: $e');
      throw Exception('Failed to pause torrent: $e');
    }
  }

  Future<bool> resumeTorrent(String hash) async {
    if (baseUrl == null) throw Exception('Server URL not set');
    if (_sid == null) throw Exception('Not logged in');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v2/torrents/resume'),
        headers: {
          'Cookie': 'SID=$_sid',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {'hashes': hash},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Resume torrent error: $e');
      throw Exception('Failed to resume torrent: $e');
    }
  }

  Future<bool> deleteTorrent(String hash) async {
    if (baseUrl == null) throw Exception('Server URL not set');
    if (_sid == null) throw Exception('Not logged in');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v2/torrents/delete'),
        headers: {
          'Cookie': 'SID=$_sid',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {'hashes': hash},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Delete torrent error: $e');
      throw Exception('Failed to delete torrent: $e');
    }
  }
}
