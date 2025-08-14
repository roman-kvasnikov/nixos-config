// main.js для Discord
const {
	app,
	BrowserWindow,
	Menu,
	session,
	nativeImage,
	Tray,
} = require('electron')
const path = require('path')

// Устанавливаем имя приложения
app.setName('discord-electron')
app.setDesktopName('discord-electron')

let mainWindow
let tray

// ВАЖНО: User Agent от реального Chrome браузера
const USER_AGENT =
	'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'

function createWindow() {
	// Создаем главное окно
	mainWindow = new BrowserWindow({
		width: 1200,
		height: 800,
		title: 'Discord',
		icon: path.join(__dirname, 'icon.png'),
		webPreferences: {
			nodeIntegration: false,
			contextIsolation: true,
			webviewTag: false,
			spellcheck: true,
			partition: 'persist:discord',
			webSecurity: true,
			allowRunningInsecureContent: false,
		},
		autoHideMenuBar: true,
		backgroundColor: '#1a1a1a',
	})

	// КРИТИЧЕСКИ ВАЖНО: Настройка сессии перед загрузкой
	const ses = session.fromPartition('persist:discord')

	// Устанавливаем User Agent для всей сессии
	ses.setUserAgent(USER_AGENT)

	// Разрешаем необходимые функции для Cloudflare
	ses.webRequest.onBeforeSendHeaders((details, callback) => {
		details.requestHeaders['User-Agent'] = USER_AGENT
		// Добавляем заголовки как у настоящего браузера
		details.requestHeaders['Accept'] =
			'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8'
		details.requestHeaders['Accept-Language'] = 'en-US,en;q=0.9'
		details.requestHeaders['Accept-Encoding'] = 'gzip, deflate, br'
		details.requestHeaders['Sec-Ch-Ua'] =
			'"Google Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"'
		details.requestHeaders['Sec-Ch-Ua-Mobile'] = '?0'
		details.requestHeaders['Sec-Ch-Ua-Platform'] = '"Linux"'
		details.requestHeaders['Sec-Fetch-Dest'] = 'document'
		details.requestHeaders['Sec-Fetch-Mode'] = 'navigate'
		details.requestHeaders['Sec-Fetch-Site'] = 'none'
		details.requestHeaders['Upgrade-Insecure-Requests'] = '1'

		callback({ requestHeaders: details.requestHeaders })
	})

	// Включаем WebGL и другие функции, которые проверяет Cloudflare
	app.commandLine.appendSwitch('enable-webgl')
	app.commandLine.appendSwitch('enable-accelerated-2d-canvas')
	app.commandLine.appendSwitch('enable-gpu-rasterization')
	app.commandLine.appendSwitch('ignore-gpu-blocklist')

	// Отключаем automation режим
	app.commandLine.appendSwitch('disable-blink-features', 'AutomationControlled')

	// Загружаем Discord
	mainWindow.loadURL('https://discord.com/channels/@me', {
		userAgent: USER_AGENT,
	})

	// Инжектим скрипт для обхода детекции автоматизации
	mainWindow.webContents.on('did-finish-load', () => {
		mainWindow.webContents.executeJavaScript(`
      // Удаляем признаки автоматизации
      Object.defineProperty(navigator, 'webdriver', {
        get: () => undefined
      });
      
      // Переопределяем navigator.plugins для имитации реального браузера
      Object.defineProperty(navigator, 'plugins', {
        get: () => [1, 2, 3, 4, 5]
      });
      
      // Имитируем наличие chrome
      window.chrome = {
        runtime: {},
        loadTimes: function() {},
        csi: function() {},
        app: {}
      };
      
      // Переопределяем navigator.permissions
      const originalQuery = window.navigator.permissions.query;
      window.navigator.permissions.query = (parameters) => (
        parameters.name === 'notifications' ?
          Promise.resolve({ state: Notification.permission }) :
          originalQuery(parameters)
      );
    `)
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
				'clipboard-write',
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
					label: 'Reload',
					accelerator: 'Ctrl+R',
					click: () => {
						mainWindow.reload()
					},
				},
				{
					label: 'Clear Data & Reload',
					accelerator: 'Ctrl+Shift+R',
					click: async () => {
						const ses = session.fromPartition('persist:discord')
						await ses.clearStorageData()
						mainWindow.reload()
					},
				},
				{ type: 'separator' },
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
			label: 'Show Discord',
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

	tray.setToolTip('Discord')
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

// Обработка активации приложения
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
