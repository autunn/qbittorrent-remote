import 'package:flutter/material.dart';
import '../models/torrent.dart';

class TorrentListItem extends StatelessWidget {
  final Torrent torrent;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onDelete;

  const TorrentListItem({
    Key? key,
    required this.torrent,
    this.onPause,
    this.onResume,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          torrent.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: torrent.progress,
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(height: 4),
            Text(
              '${(torrent.progress * 100).toStringAsFixed(1)}% - '
              '${_formatSpeed(torrent.downloadSpeed)}/s - '
              'ETA: ${_formatEta(torrent.eta)}',
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (torrent.state == 'downloading')
              IconButton(
                icon: Icon(Icons.pause),
                onPressed: onPause,
              )
            else
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: onResume,
              ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatSpeed(int speed) {
    if (speed < 1024) return '$speed B';
    if (speed < 1024 * 1024) return '${(speed / 1024).toStringAsFixed(1)} KB';
    if (speed < 1024 * 1024 * 1024) return '${(speed / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(speed / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatEta(int seconds) {
    if (seconds < 0) return 'Unknown';
    if (seconds < 60) return '$seconds s';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(0)} m';
    if (seconds < 86400) return '${(seconds / 3600).toStringAsFixed(0)} h';
    return '${(seconds / 86400).toStringAsFixed(0)} d';
  }
} 