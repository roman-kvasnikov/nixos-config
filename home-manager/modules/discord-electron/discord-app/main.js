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

// User Agent от реального Chrome браузера
const USER_AGENT =
	'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'

function createWindow() {
	// ВАЖНО: Получаем персистентную сессию ДО создания окна
	const ses = session.fromPartition('persist:discord')

	// Настраиваем cookies для длительного хранения
	ses.cookies.flushStore(() => {
		console.log('Cookie store initialized')
	})

	// Создаем главное окно с персистентной сессией
	mainWindow = new BrowserWindow({
		width: 1280,
		height: 720,
		title: 'Discord',
		icon: path.join(__dirname, 'icon.png'),
		webPreferences: {
			nodeIntegration: false,
			contextIsolation: true,
			webviewTag: false,
			spellcheck: true,
			partition: 'persist:discord', // Персистентная сессия для сохранения логина
			webSecurity: true,
			// Добавляем дополнительные настройки для сохранения данных
			backgroundThrottling: false,
			offscreen: false,
		},
		autoHideMenuBar: true,
		backgroundColor: '#202225',
		// Сохраняем размеры и позицию окна
		show: false,
	})

	// Показываем окно когда оно готово
	mainWindow.once('ready-to-show', () => {
		mainWindow.show()
	})

	// Устанавливаем User Agent для всей сессии
	ses.setUserAgent(USER_AGENT)

	// Разрешаем необходимые функции для Discord
	ses.webRequest.onBeforeSendHeaders((details, callback) => {
		details.requestHeaders['User-Agent'] = USER_AGENT
		details.requestHeaders['Accept'] =
			'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8'
		details.requestHeaders['Accept-Language'] = 'en-US,en;q=0.9'
		details.requestHeaders['Accept-Encoding'] = 'gzip, deflate, br'
		details.requestHeaders['Sec-Ch-Ua'] =
			'"Google Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"'
		details.requestHeaders['Sec-Ch-Ua-Mobile'] = '?0'
		details.requestHeaders['Sec-Ch-Ua-Platform'] = '"Linux"'

		callback({ requestHeaders: details.requestHeaders })
	})

	// Включаем функции, необходимые для Discord
	app.commandLine.appendSwitch('enable-webgl')
	app.commandLine.appendSwitch('enable-accelerated-2d-canvas')
	app.commandLine.appendSwitch('enable-gpu-rasterization')
	app.commandLine.appendSwitch('ignore-gpu-blocklist')

	// Отключаем automation режим
	app.commandLine.appendSwitch('disable-blink-features', 'AutomationControlled')

	// Включаем аудио/видео функции для Discord
	app.commandLine.appendSwitch('use-fake-ui-for-media-stream')
	app.commandLine.appendSwitch('enable-media-stream')

	// Загружаем Discord с дополнительными заголовками
	mainWindow.loadURL('https://discord.com/app', {
		userAgent: USER_AGENT,
		httpReferrer: 'https://discord.com/',
		extraHeaders: 'pragma: no-cache\n',
	})

	// Обрабатываем навигацию для сохранения токена
	mainWindow.webContents.on('did-navigate', (event, url) => {
		console.log('Navigated to:', url)
	})

	// Инжектим скрипт для сохранения localStorage и токена
	mainWindow.webContents.on('did-finish-load', () => {
		mainWindow.webContents.executeJavaScript(`
      // Удаляем признаки автоматизации
      Object.defineProperty(navigator, 'webdriver', {
        get: () => undefined
      });
      
      // Переопределяем navigator.plugins
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
      
      // Сохраняем localStorage при изменениях
      const originalSetItem = localStorage.setItem;
      localStorage.setItem = function(key, value) {
        originalSetItem.apply(this, arguments);
        // Принудительно сохраняем
        if (key.includes('token') || key.includes('auth')) {
          console.log('Saving auth data:', key);
        }
      };
    `)
	})

	// Обработка внешних ссылок
	mainWindow.webContents.setWindowOpenHandler(({ url }) => {
		// Разрешаем открытие окон авторизации Discord
		if (
			url.includes('discord.com/oauth') ||
			url.includes('discord.com/login')
		) {
			return {
				action: 'allow',
				overrideBrowserWindowOptions: {
					width: 500,
					height: 700,
					autoHideMenuBar: true,
				},
			}
		}
		// Внешние ссылки открываем в браузере
		if (!url.includes('discord.com')) {
			require('electron').shell.openExternal(url)
			return { action: 'deny' }
		}
		return { action: 'allow' }
	})

	// Настройка разрешений
	ses.setPermissionRequestHandler((webContents, permission, callback) => {
		const allowedPermissions = [
			'notifications',
			'media',
			'mediaKeySystem',
			'clipboard-read',
			'clipboard-write',
			'microphone', // Для голосовых чатов
			'camera', // Для видео
			'audioCapture',
			'videoCapture',
			'displayCapture', // Для демонстрации экрана
			'persistent-storage',
		]
		if (allowedPermissions.includes(permission)) {
			callback(true)
		} else {
			callback(false)
		}
	})

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
					label: 'Force Reload',
					accelerator: 'Ctrl+Shift+R',
					click: () => {
						mainWindow.webContents.reloadIgnoringCache()
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

// ВАЖНО: Устанавливаем путь для userData ДО app.whenReady()
// Это критически важно для сохранения сессии
const userDataPath = path.join(app.getPath('appData'), 'discord-electron')
app.setPath('userData', userDataPath)

// Убеждаемся, что используем правильный путь для сессии
app.setPath('sessionData', path.join(userDataPath, 'Session'))

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
