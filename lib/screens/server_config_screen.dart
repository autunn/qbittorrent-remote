import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/qbittorrent_api.dart';
import '../constants/app_constants.dart';
import 'login_screen.dart';

class ServerConfigScreen extends StatefulWidget {
  @override
  _ServerConfigScreenState createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final _urlController = TextEditingController();
  final _prefs = SharedPreferences.getInstance();

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

  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter server URL')),
      );
      return;
    }

    final formattedUrl = url.startsWith('http') ? url : 'http://$url';

    try {
      final api = Provider.of<QBittorrentAPI>(context, listen: false);
      api.setBaseUrl(formattedUrl);

      final prefs = await _prefs;
      await prefs.setString(AppConstants.serverUrlKey, formattedUrl);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid server URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Server Configuration')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Server URL',
                hintText: 'Example: http://192.168.1.100:8080',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUrl,
              child: Text('Connect to Server'),
            ),
          ],
        ),
      ),
    );
  }
} 