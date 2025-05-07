class AppConstants {
  static const String appTitle = 'qBittorrent Remote';
  static const int refreshInterval = 5; // seconds
  static const String serverUrlKey = 'server_url';
  
  // API Endpoints
  static const String loginEndpoint = '/api/v2/auth/login';
  static const String logoutEndpoint = '/api/v2/auth/logout';
  static const String torrentsEndpoint = '/api/v2/torrents/info';
  static const String torrentAddEndpoint = '/api/v2/torrents/add';
  static const String torrentDeleteEndpoint = '/api/v2/torrents/delete';
  static const String torrentPauseEndpoint = '/api/v2/torrents/pause';
  static const String torrentResumeEndpoint = '/api/v2/torrents/resume';
} 