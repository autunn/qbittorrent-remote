import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../api/qbittorrent_api.dart';
import '../constants/strings.dart';

class TorrentListScreen extends StatefulWidget {
  @override
  _TorrentListScreenState createState() => _TorrentListScreenState();
}

class _TorrentListScreenState extends State<TorrentListScreen> {
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
      print('${Strings.error}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.torrents),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTorrents,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddTorrentDialog();
            },
          ),
        ],
      ),
      body: _buildTorrentList(),
    );
  }

  Widget _buildTorrentList() {
    if (_torrents.isEmpty) {
      return Center(
        child: Text(Strings.noTorrentsFound),
      );
    }

    return ListView.builder(
      itemCount: _torrents.length,
      itemBuilder: (context, index) {
        final torrent = _torrents[index];
        final state = torrent['state'] as String? ?? 'unknown';
        final stateText = Strings.torrentStates[state] ?? Strings.unknown;
        
        return ListTile(
          title: Text(torrent['name'] ?? Strings.unknown),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${Strings.progress}: ${((torrent['progress'] ?? 0) * 100).toStringAsFixed(1)}%'),
              Text('${Strings.status}: $stateText'),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(torrent['hash']),
          ),
        );
      },
    );
  }

  Future<void> _showAddTorrentDialog() async {
    final urlController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Strings.addTorrent),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(
            labelText: Strings.magnetUrlOrTorrentFileUrl,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (urlController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(Strings.pleaseEnterUrl)),
                );
                return;
              }
              Navigator.pop(context);
              try {
                final success = await _api.addTorrent(urlController.text);
                if (success) {
                  _loadTorrents();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${Strings.failedToAddTorrent}: $e')),
                );
              }
            },
            child: Text(Strings.add),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String hash) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Strings.confirmDelete),
        content: Text(Strings.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(Strings.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteTorrent(hash);
    }
  }

  Future<void> _deleteTorrent(String hash) async {
    try {
      final success = await _api.deleteTorrent(hash);
      if (success) {
        _loadTorrents();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Strings.failedToDeleteTorrent}: $e')),
      );
    }
  }
} 