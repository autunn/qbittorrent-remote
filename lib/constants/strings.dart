class Strings {
  static const appTitle = 'qBittorrent 远程管理';
  
  // 服务器配置页面
  static const serverConfig = '服务器配置';
  static const serverUrl = '服务器地址';
  static const serverUrlHint = '例如: http://192.168.1.100:8080';
  static const connectToServer = '连接服务器';
  static const pleaseEnterServerUrl = '请输入服务器地址';
  static const invalidServerUrl = '无效的服务器地址';
  
  // 登录页面
  static const login = '登录';
  static const username = '用户名';
  static const password = '密码';
  static const loginFailed = '登录失败';
  static const server = '服务器';
  
  // Torrent 列表页面
  static const torrents = '种子列表';
  static const addTorrent = '添加种子';
  static const deleteTorrent = '删除种子';
  static const confirmDelete = '确认删除';
  static const confirmDeleteMessage = '确定要删除这个种子吗？';
  static const cancel = '取消';
  static const delete = '删除';
  static const progress = '进度';
  static const status = '状态';
  static const unknown = '未知';
  static const magnetUrlOrTorrentFileUrl = '磁力链接或种子文件地址';
  static const add = '添加';
  static const failedToAddTorrent = '添加种子失败';
  static const failedToDeleteTorrent = '删除种子失败';
  static const noTorrentsFound = '没有找到种子';
  static const pleaseEnterUrl = '请输入链接地址';
  
  // 错误信息
  static const error = '错误';
  
  // 状态文本
  static const Map<String, String> torrentStates = {
    'downloading': '下载中',
    'uploading': '上传中',
    'pausedDL': '暂停下载',
    'pausedUP': '暂停上传',
    'queuedDL': '等待下载',
    'queuedUP': '等待上传',
    'checkingDL': '检查下载',
    'checkingUP': '检查上传',
    'checking': '检查中',
    'stalledDL': '下载停滞',
    'stalledUP': '上传停滞',
    'error': '错误',
    'missingFiles': '文件缺失',
    'unknown': '未知状态',
  };
} 