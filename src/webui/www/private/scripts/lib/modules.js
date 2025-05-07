/**
 * Module system for qBittorrent Web UI
 * Manages module dependencies and initialization
 */

const ModuleSystem = {
    modules: new Map(),
    dependencies: new Map(),
    
    // Register a module
    register: function(name, module, deps = []) {
        this.modules.set(name, module);
        this.dependencies.set(name, deps);
    },
    
    // Initialize a module and its dependencies
    init: function(name) {
        const module = this.modules.get(name);
        if (!module) {
            console.error(`Module ${name} not found`);
            return;
        }
        
        // Initialize dependencies first
        const deps = this.dependencies.get(name) || [];
        deps.forEach(dep => this.init(dep));
        
        // Initialize the module if it has an init function
        if (typeof module.init === 'function') {
            module.init();
        }
    },
    
    // Get a module
    get: function(name) {
        return this.modules.get(name);
    }
};

// Export to global scope
window.ModuleSystem = ModuleSystem; 