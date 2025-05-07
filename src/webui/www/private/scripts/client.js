/**
 * qBittorrent Web UI Client
 * Main client-side JavaScript file for qBittorrent Web UI
 */

// Core module
const CoreModule = {
    state: {
        torrentsTable: null,
        uploadLimit: 0,
        downloadLimit: 0,
        isConnected: false
    },
    
    init: function() {
        this.initTorrentsTable();
        this.initEventListeners();
    },
    
    initTorrentsTable: function() {
        this.state.torrentsTable = new window.qBittorrent.DynamicTable.TorrentsTable();
    },
    
    initEventListeners: function() {
        document.addEventListener('DOMContentLoaded', () => {
            this.onDocumentReady();
        });
    },
    
    onDocumentReady: function() {
        // Initialize all required modules
        ModuleSystem.init('core');
        ModuleSystem.init('ui');
        ModuleSystem.init('torrents');
    },
    
    // Public API
    getState: function() {
        return this.state;
    },
    
    setUploadLimit: function(limit) {
        this.state.uploadLimit = limit;
        globalUploadLimitFN(limit);
    },
    
    setDownloadLimit: function(limit) {
        this.state.downloadLimit = limit;
    },
    
    updatePropertiesPanel: function() {
        // Implementation will be added
    }
};

// UI module
const UIModule = {
    init: function() {
        this.initSelectBoxes();
        this.initModals();
    },
    
    initSelectBoxes: function() {
        // Initialize vanilla select boxes
        document.querySelectorAll('.vanilla-select').forEach(select => {
            new VanillaSelectBox(select);
        });
    },
    
    initModals: function() {
        // Initialize modal windows
        if (window.MUI) {
            MUI.initialize();
        }
    }
};

// Torrents module
const TorrentsModule = {
    init: function() {
        this.initTable();
        this.initEventHandlers();
    },
    
    initTable: function() {
        const core = ModuleSystem.get('core');
        this.table = core.state.torrentsTable;
    },
    
    initEventHandlers: function() {
        // Add torrent-related event handlers
    }
};

// Register modules
ModuleSystem.register('core', CoreModule);
ModuleSystem.register('ui', UIModule, ['core']);
ModuleSystem.register('torrents', TorrentsModule, ['core', 'ui']);

// Initialize core module
ModuleSystem.init('core'); 