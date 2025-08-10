const { GObject, St, Clutter, Gio, GLib } = imports.gi;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

class XrayToggleIndicator extends PanelMenu.Button {
    _init() {
        super._init(0.0, 'Xray Toggle');
        
        // Иконка в панели
        this._icon = new St.Icon({
            icon_name: 'network-vpn-symbolic',
            style_class: 'system-status-icon'
        });
        this.add_child(this._icon);
        
        // Статус прокси (по умолчанию выключен)
        this._proxyEnabled = false;
        this._updateIcon();
        
        // Меню
        this._createMenu();
        
        // Обновляем статус при запуске
        this._checkStatus();
    }
    
    _createMenu() {
        // Кнопка включения/выключения
        this._toggleItem = new PopupMenu.PopupMenuItem('Включить Xray');
        this._toggleItem.connect('activate', () => {
            this._toggleProxy();
        });
        this.menu.addMenuItem(this._toggleItem);
        
        // Разделитель
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        
        // Статус
        this._statusItem = new PopupMenu.PopupMenuItem('Статус: Выключен', {
            reactive: false
        });
        this.menu.addMenuItem(this._statusItem);
    }
    
    _toggleProxy() {
        if (this._proxyEnabled) {
            this._executeCommand('xrayctl all-off');
        } else {
            this._executeCommand('xrayctl all-on');
        }
    }
    
    _executeCommand(command) {
        try {
            let proc = Gio.Subprocess.new(
                ['bash', '-c', command],
                Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
            );
            
            proc.communicate_utf8_async(null, null, (proc, res) => {
                try {
                    let [, stdout, stderr] = proc.communicate_utf8_finish(res);
                    
                    // Обновляем статус после выполнения команды
                    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
                        this._checkStatus();
                        return GLib.SOURCE_REMOVE;
                    });
                    
                } catch (e) {
                    log(`Xray Toggle Error: ${e}`);
                }
            });
            
        } catch (e) {
            log(`Xray Toggle Error: ${e}`);
        }
    }
    
    _checkStatus() {
        // Проверяем статус через команду ps или проверку процесса
        try {
            let proc = Gio.Subprocess.new(
                ['pgrep', '-f', 'xray'],
                Gio.SubprocessFlags.STDOUT_PIPE
            );
            
            proc.communicate_utf8_async(null, null, (proc, res) => {
                try {
                    let [, stdout] = proc.communicate_utf8_finish(res);
                    let wasEnabled = this._proxyEnabled;
                    this._proxyEnabled = stdout.trim().length > 0;
                    
                    if (wasEnabled !== this._proxyEnabled) {
                        this._updateIcon();
                        this._updateMenu();
                    }
                } catch (e) {
                    // Если pgrep не нашел процесс, значит выключен
                    this._proxyEnabled = false;
                    this._updateIcon();
                    this._updateMenu();
                }
            });
            
        } catch (e) {
            log(`Xray Status Check Error: ${e}`);
        }
    }
    
    _updateIcon() {
        if (this._proxyEnabled) {
            this._icon.style_class = 'system-status-icon xray-enabled';
            this._icon.set_style('color: #4CAF50;'); // Зеленый
        } else {
            this._icon.style_class = 'system-status-icon xray-disabled';
            this._icon.set_style('color: #F44336;'); // Красный
        }
    }
    
    _updateMenu() {
        if (this._proxyEnabled) {
            this._toggleItem.label.text = 'Выключить Xray';
            this._statusItem.label.text = 'Статус: Включен';
        } else {
            this._toggleItem.label.text = 'Включить Xray';
            this._statusItem.label.text = 'Статус: Выключен';
        }
    }
    
    destroy() {
        super.destroy();
    }
}

class Extension {
    constructor() {
        this._indicator = null;
    }
    
    enable() {
        log('Enabling Xray Toggle extension');
        this._indicator = new XrayToggleIndicator();
        Main.panel.addToStatusArea('xray-toggle', this._indicator);
    }
    
    disable() {
        log('Disabling Xray Toggle extension');
        if (this._indicator) {
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}

function init() {
    return new Extension();
}