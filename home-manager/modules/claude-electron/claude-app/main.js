// main.js
const {
	app,
	BrowserWindow,
	Menu,
	session,
	nativeImage,
	Tray,
} = require('electron')
const path = require('path')

// Устанавливаем имя приложения до создания окон
app.setName('claude-electron')
app.setDesktopName('claude-electron')

let mainWindow
let tray

// Настройки для Claude
const USER_AGENT =
	'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'

function createWindow() {
	// Создаем главное окно
	mainWindow = new BrowserWindow({
		width: 1200,
		height: 800,
		title: 'Claude',
		icon: path.join(__dirname, 'icon.png'),
		webPreferences: {
			nodeIntegration: false,
			contextIsolation: true,
			webviewTag: false,
			spellcheck: true,
			partition: 'persist:claude',
		},
		autoHideMenuBar: true,
		backgroundColor: '#131C21',
	})

	// Устанавливаем User Agent для совместимости
	mainWindow.webContents.setUserAgent(USER_AGENT)

	// Загружаем Claude
	mainWindow.loadURL('https://claude.ai', {
		userAgent: USER_AGENT,
	})

	// Обработка внешних ссылок
	mainWindow.webContents.setWindowOpenHandler(({ url }) => {
		require('electron').shell.openExternal(url)
		return { action: 'deny' }
	})

	// Настройка разрешений
	session.defaultSession.setPermissionRequestHandler(
		(webContents, permission, callback) => {
			const allowedPermissions = [
				'notifications',
				'media',
				'mediaKeySystem',
				'clipboard-read',
			]
			if (allowedPermissions.includes(permission)) {
				callback(true)
			} else {
				callback(false)
			}
		}
	)

	// Обработка закрытия окна
	mainWindow.on('close', event => {
		if (!app.isQuitting) {
			event.preventDefault()
			mainWindow.hide()
		}
	})

	// Настройка меню
	const template = [
		{
			label: 'File',
			submenu: [
				{
					label: 'Quit',
					accelerator: 'Ctrl+Q',
					click: () => {
						app.isQuitting = true
						app.quit()
					},
				},
			],
		},
		{
			label: 'Edit',
			submenu: [
				{ role: 'undo' },
				{ role: 'redo' },
				{ type: 'separator' },
				{ role: 'cut' },
				{ role: 'copy' },
				{ role: 'paste' },
				{ role: 'selectAll' },
			],
		},
		{
			label: 'View',
			submenu: [
				{ role: 'reload' },
				{ role: 'forceReload' },
				{ role: 'toggleDevTools' },
				{ type: 'separator' },
				{ role: 'resetZoom' },
				{ role: 'zoomIn' },
				{ role: 'zoomOut' },
				{ type: 'separator' },
				{ role: 'togglefullscreen' },
			],
		},
	]

	const menu = Menu.buildFromTemplate(template)
	Menu.setApplicationMenu(menu)
}

// Создание иконки в трее
function createTray() {
	tray = new Tray(path.join(__dirname, 'icon.png'))

	const contextMenu = Menu.buildFromTemplate([
		{
			label: 'Show Claude',
			click: () => {
				mainWindow.show()
			},
		},
		{
			label: 'Quit',
			click: () => {
				app.isQuitting = true
				app.quit()
			},
		},
	])

	tray.setToolTip('Claude')
	tray.setContextMenu(contextMenu)

	tray.on('click', () => {
		mainWindow.isVisible() ? mainWindow.hide() : mainWindow.show()
	})
}

// Запуск приложения
app.whenReady().then(() => {
	createWindow()
	createTray()
})

// Обработка активации приложения (macOS)
app.on('activate', () => {
	if (BrowserWindow.getAllWindows().length === 0) {
		createWindow()
	} else {
		mainWindow.show()
	}
})

// Предотвращение закрытия при закрытии всех окон
app.on('window-all-closed', event => {
	event.preventDefault()
})

// package.json
const packageJson = {
	name: 'claude-electron',
	version: '1.0.0',
	description: 'Claude in Electron',
	main: 'main.js',
	scripts: {
		start: 'electron .',
		build: "echo 'Build complete'",
	},
	keywords: ['claude', 'electron', 'ai', 'chat'],
	author: '',
	license: 'MIT',
	devDependencies: {
		electron: '^28.0.0',
	},
}
