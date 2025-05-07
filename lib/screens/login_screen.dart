import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/qbittorrent_api.dart';
import 'server_config_screen.dart';
import 'torrent_list_screen.dart';
import '../constants/strings.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<QBittorrentAPI>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.login),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ServerConfigScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${Strings.server}: ${api.baseUrl}'),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: Strings.username),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: Strings.password),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final success = await api.login(
                    _usernameController.text,
                    _passwordController.text,
                  );
                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TorrentListScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(Strings.loginFailed)),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${Strings.error}: ${e.toString()}')),
                  );
                }
              },
              child: Text(Strings.login),
            ),
          ],
        ),
      ),
    );
  }
} 