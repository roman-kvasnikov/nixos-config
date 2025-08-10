import GObject from 'gi://GObject'
import St from 'gi://St'
import Gio from 'gi://Gio'
import GLib from 'gi://GLib'

import * as Main from 'resource:///org/gnome/shell/ui/main.js'
import * as QuickSettings from 'resource:///org/gnome/shell/ui/quickSettings.js'
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js'
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js'

import {
	Extension,
	gettext as _,
} from 'resource:///org/gnome/shell/extensions/extension.js'

// Кастомная кнопка для Quick Settings (исправлена для GNOME 48)
const XrayQuickToggle = GObject.registerClass(
	class XrayQuickToggle extends QuickSettings.QuickSettingsButton {
		_init() {
			super._init({
				iconName: 'network-vpn-symbolic',
				label: 'Xray Proxy',
				tooltipText: 'Toggle Xray proxy service',
			})

			// Статус прокси (по умолчанию выключен)
			this._proxyEnabled = false
			this._updateToggle()

			// Обновляем статус при запуске
			this._checkStatus()

			// Обработчик клика
			this.connect('clicked', () => {
				this._toggleProxy()
			})

			// Добавляем стили
			this.add_style_class_name('xray-toggle-button')
		}

		_toggleProxy() {
			if (this._proxyEnabled) {
				this._executeCommand('xrayctl all-off')
			} else {
				this._executeCommand('xrayctl all-on')
			}
		}

		_executeCommand(command) {
			try {
				let proc = Gio.Subprocess.new(
					['bash', '-c', command],
					Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
				)

				proc.communicate_utf8_async(null, null, (proc, res) => {
					try {
						let [, stdout, stderr] = proc.communicate_utf8_finish(res)

						// Обновляем статус после выполнения команды
						GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
							this._checkStatus()
							return GLib.SOURCE_REMOVE
						})
					} catch (e) {
						log(`Xray Toggle Error: ${e}`)
					}
				})
			} catch (e) {
				log(`Xray Toggle Error: ${e}`)
			}
		}

		_checkStatus() {
			// Проверяем статус через команду ps или проверку процесса
			try {
				let proc = Gio.Subprocess.new(
					['pgrep', '-f', 'xray'],
					Gio.SubprocessFlags.STDOUT_PIPE
				)

				proc.communicate_utf8_async(null, null, (proc, res) => {
					try {
						let [, stdout] = proc.communicate_utf8_finish(res)
						let wasEnabled = this._proxyEnabled
						this._proxyEnabled = stdout.trim().length > 0

						if (wasEnabled !== this._proxyEnabled) {
							this._updateToggle()
						}
					} catch (e) {
						// Если pgrep не нашел процесс, значит выключен
						this._proxyEnabled = false
						this._updateToggle()
					}
				})
			} catch (e) {
				log(`Xray Status Check Error: ${e}`)
			}
		}

		_updateToggle() {
			if (this._proxyEnabled) {
				this.set({ label: 'Xray Proxy (ON)' })
				this.add_style_class_name('xray-enabled')
				this.remove_style_class_name('xray-disabled')
				// Изменяем цвет иконки на зеленый
				this.set({ iconName: 'network-vpn-symbolic' })
			} else {
				this.set({ label: 'Xray Proxy (OFF)' })
				this.add_style_class_name('xray-disabled')
				this.remove_style_class_name('xray-enabled')
				// Изменяем цвет иконки на красный
				this.set({ iconName: 'network-vpn-symbolic' })
			}
		}

		destroy() {
			super.destroy()
		}
	}
)

export default class XrayToggleExtension extends Extension {
	constructor(metadata) {
		super(metadata)
		this._quickToggle = null
	}

	enable() {
		console.log('Enabling Xray Toggle extension for GNOME 48')

		try {
			// Создаем кнопку в Quick Settings
			this._quickToggle = new XrayQuickToggle()
			QuickSettings.QuickSettingsMenu.addItem(this._quickToggle)
			console.log('Xray Quick Toggle added successfully')
		} catch (error) {
			console.error('Error adding Xray Quick Toggle:', error)
			// Fallback: создаем обычную панельную кнопку
			this._createPanelButton()
		}
	}

	_createPanelButton() {
		console.log('Creating fallback panel button')
		// Создаем обычную кнопку в панели как fallback
		this._panelButton = new PanelMenu.Button(0.0, 'Xray Toggle')

		let icon = new St.Icon({
			icon_name: 'network-vpn-symbolic',
			style_class: 'system-status-icon',
		})
		this._panelButton.add_child(icon)

		// Добавляем в панель
		Main.panel.addToStatusArea('xray-toggle', this._panelButton)
	}

	disable() {
		console.log('Disabling Xray Toggle extension')

		if (this._quickToggle) {
			this._quickToggle.destroy()
			this._quickToggle = null
		}

		if (this._panelButton) {
			this._panelButton.destroy()
			this._panelButton = null
		}
	}
}
