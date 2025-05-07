import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'api/qbittorrent_api.dart';
import 'screens/server_config_screen.dart';
import 'screens/login_screen.dart';
import 'screens/torrent_list_screen.dart';
import 'constants/strings.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => QBittorrentAPI(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ServerConfigScreen(),
    );
  }
}

class ServerConfigPage extends StatefulWidget {
  @override
  _ServerConfigPageState createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  final _urlController = TextEditingController();
  final _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final prefs = await _prefs;
    final savedUrl = prefs.getString('server_url');
    if (savedUrl != null) {
      _urlController.text = savedUrl;
      final api = Provider.of<QBittorrentAPI>(context, listen: false);
      api.setBaseUrl(savedUrl);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
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

    // Add http:// if not present
    final formattedUrl = url.startsWith('http') ? url : 'http://$url';

    try {
      final api = Provider.of<QBittorrentAPI>(context, listen: false);
      api.setBaseUrl(formattedUrl);

      final prefs = await _prefs;
      await prefs.setString('server_url', formattedUrl);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
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
              ),
            ),
            SizedBox(height: 20),
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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<QBittorrentAPI>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ServerConfigPage()),
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
            Text('Server: ${api.baseUrl}'),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
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
                      MaterialPageRoute(builder: (context) => TorrentListPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login failed')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class TorrentListPage extends StatefulWidget {
  @override
  _TorrentListPageState createState() => _TorrentListPageState();
}

class _TorrentListPageState extends State<TorrentListPage> {
  List<dynamic> _torrents = [];
  Timer? _refreshTimer;
  final _api = QBittorrentAPI();

  @override
  void initState() {
    super.initState();
    _loadTorrents();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _loadTorrents();
    });
  }

  Future<void> _loadTorrents() async {
    try {
      final torrents = await _api.getTorrents();
      setState(() {
        _torrents = torrents;
      });
    } catch (e) {
      print('Error loading torrents: $e');
    }
  }

  Future<void> _addTorrent() async {
    final TextEditingController urlController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Torrent'),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(
            labelText: 'Torrent URL',
            hintText: 'Enter magnet link or torrent URL',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (urlController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a URL')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              try {
                final success = await _api.addTorrent(urlController.text);
                if (success) {
                  _loadTorrents();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add torrent')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Torrents'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTorrents,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ServerConfigPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTorrents,
        child: Consumer<QBittorrentAPI>(
          builder: (context, api, child) {
            if (_torrents.isEmpty) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return ListView.builder(
              itemCount: _torrents.length,
              itemBuilder: (context, index) {
                final torrent = _torrents[index];
                return ListTile(
                  title: Text(torrent['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progress: ${(torrent['progress'] * 100).toStringAsFixed(1)}%'),
                      Text(
                        'Status: ${torrent['state']}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          torrent['state'] == 'pausedUP' || torrent['state'] == 'pausedDL'
                              ? Icons.play_arrow
                              : Icons.pause,
                        ),
                        onPressed: () async {
                          try {
                            if (torrent['state'] == 'pausedUP' || torrent['state'] == 'pausedDL') {
                              await api.resumeTorrent(torrent['hash']);
                            } else {
                              await api.pauseTorrent(torrent['hash']);
                            }
                            _loadTorrents();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Torrent'),
                              content: Text('Are you sure you want to delete this torrent?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            try {
                              await api.deleteTorrent(torrent['hash']);
                              _loadTorrents();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTorrent,
        child: Icon(Icons.add),
      ),
    );
  }
} 