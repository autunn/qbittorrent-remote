class Torrent {
  final String name;
  final double progress;
  final String state;
  final int size;
  final int downloaded;
  final int uploaded;
  final int downloadSpeed;
  final int uploadSpeed;
  final int eta;
  final String hash;

  Torrent({
    required this.name,
    required this.progress,
    required this.state,
    required this.size,
    required this.downloaded,
    required this.uploaded,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.eta,
    required this.hash,
  });

  factory Torrent.fromJson(Map<String, dynamic> json) {
    return Torrent(
      name: json['name'] ?? '',
      progress: (json['progress'] ?? 0.0).toDouble(),
      state: json['state'] ?? '',
      size: json['size'] ?? 0,
      downloaded: json['downloaded'] ?? 0,
      uploaded: json['uploaded'] ?? 0,
      downloadSpeed: json['dlspeed'] ?? 0,
      uploadSpeed: json['upspeed'] ?? 0,
      eta: json['eta'] ?? 0,
      hash: json['hash'] ?? '',
    );
  }
} 