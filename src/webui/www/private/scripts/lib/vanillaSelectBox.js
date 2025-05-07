/**
 * VanillaSelectBox Module
 * A lightweight, vanilla JavaScript select box replacement
 */

const VanillaSelectBoxModule = {
    // Default options
    defaults: {
        maxWidth: 500,
        minWidth: -1,
        maxHeight: 400,
        translations: {
            all: "All",
            item: "item",
            items: "items",
            selectAll: "Select All",
            clearAll: "Clear All"
        },
        search: false,
        placeHolder: "",
        stayOpen: false,
        disableSelectAll: false,
        buttonItemsSeparator: ","
    },
    
    // Create a new select box instance
    create: function(domSelector, options = {}) {
        return new VanillaSelectBox(domSelector, this.mergeOptions(options));
    },
    
    // Merge user options with defaults
    mergeOptions: function(options) {
        return {
            ...this.defaults,
            ...options,
            translations: {
                ...this.defaults.translations,
                ...(options.translations || {})
            }
        };
    }
};

// VanillaSelectBox class
class VanillaSelectBox {
    constructor(domSelector, options) {
        this.domSelector = domSelector;
        this.root = document.querySelector(domSelector);
        this.options = options;
        this._init();
    }

    _init() {
        this._createElements();
        this._bindEvents();
        this._setupStyles();
    }

    _createElements() {
        // Create main container
        this.main = document.createElement('div');
        this.main.className = 'vanilla-select-box';
        
        // Create button
        this.button = document.createElement('button');
        this.button.type = 'button';
        
        // Create title span
        this.title = document.createElement('span');
        this.title.className = 'title';
        this.button.appendChild(this.title);
        
        // Create dropdown
        this.drop = document.createElement('div');
        this.drop.className = 'dropdown';
        
        // Add elements to DOM
        this.main.appendChild(this.button);
        this.main.appendChild(this.drop);
        this.root.parentNode.insertBefore(this.main, this.root.nextSibling);
        this.root.style.display = 'none';
    }

    _bindEvents() {
        this.button.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            this._toggleDropdown();
        });

        document.addEventListener('click', (e) => {
            if (!this.main.contains(e.target)) {
                this._closeDropdown();
            }
        });
    }

    _setupStyles() {
        // Add basic styles
        this.main.style.position = 'relative';
        this.main.style.display = 'inline-block';
        
        this.button.style.width = '100%';
        this.button.style.textAlign = 'left';
        
        this.drop.style.position = 'absolute';
        this.drop.style.display = 'none';
        this.drop.style.zIndex = '1000';
    }

    _toggleDropdown() {
        if (this.drop.style.display === 'none') {
            this._openDropdown();
        } else {
            this._closeDropdown();
        }
    }

    _openDropdown() {
        this.drop.style.display = 'block';
    }

    _closeDropdown() {
        this.drop.style.display = 'none';
    }

    disable() {
        this.main.addEventListener("click", (e) => {
            e.preventDefault();
            e.stopPropagation();
        });
        const button = this.main.querySelector("button");
        if (button) {
            button.classList.add("disabled");
            this.isDisabled = true;
        }
    }

    enable() {
        const button = this.main.querySelector("button");
        if (button) {
            button.classList.remove("disabled");
            this.isDisabled = false;
        }
    }

    destroy() {
        if (this.main && this.main.parentNode) {
            this.main.parentNode.removeChild(this.main);
            this.root.style.display = 'inline-block';
        }
    }
}

// Register the module
ModuleSystem.register('vanillaSelectBox', VanillaSelectBoxModule);

// Export to global scope
window.VanillaSelectBox = VanillaSelectBoxModule.create; 