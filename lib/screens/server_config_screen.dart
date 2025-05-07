import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../api/qbittorrent_api.dart';
import '../constants/app_constants.dart';
import '../constants/strings.dart';
import 'login_screen.dart';

class ServerConfigScreen extends StatefulWidget {
  @override
  _ServerConfigScreenState createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final _urlController = TextEditingController();
  final _prefs = SharedPreferences.getInstance();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final prefs = await _prefs;
    final savedUrl = prefs.getString(AppConstants.serverUrlKey);
    if (savedUrl != null) {
      _urlController.text = savedUrl;
      final api = Provider.of<QBittorrentAPI>(context, listen: false);
      api.setBaseUrl(savedUrl);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  String? _validateUrl(String url) {
    if (url.isEmpty) {
      return Strings.pleaseEnterServerUrl;
    }
    
    // 确保 URL 格式正确
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'http://$url');
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return Strings.invalidServerUrl;
    }
    
    return null;
  }

  Future<void> _saveUrl() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = _urlController.text.trim();
    final validationError = _validateUrl(url);
    
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
        _isLoading = false;
      });
      return;
    }

    final formattedUrl = url.startsWith('http') ? url : 'http://$url';

    try {
      final api = Provider.of<QBittorrentAPI>(context, listen: false);
      api.setBaseUrl(formattedUrl);

      // 测试连接
      try {
        await api.login('', ''); // 尝试连接服务器
      } catch (e) {
        print('Connection test error: $e');
        // 忽略登录错误，我们只是测试连接
      }

      final prefs = await _prefs;
      await prefs.setString(AppConstants.serverUrlKey, formattedUrl);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '无法连接到服务器: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.serverConfig)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: Strings.serverUrl,
                hintText: Strings.serverUrlHint,
                errorText: _errorMessage,
              ),
              enabled: !_isLoading,
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _saveUrl,
                child: Text(Strings.connectToServer),
              ),
          ],
        ),
      ),
    );
  }
} 