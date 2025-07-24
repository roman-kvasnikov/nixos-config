{ pkgs, user, ... }:

let
  vscodeSettings = builtins.fromJSON (
    builtins.readFile "/home/${user}/.config/nixos/home-manager/modules/code-cursor/settings.json"
  );
in {
  programs.vscode = {
    enable = true;

    package = pkgs.code-cursor;

    # package = with pkgs; [code-cursor alejandra];

    enableUpdateCheck = false;

    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix # Nix language support
      esbenp.prettier-vscode # General formatting plugin
      # open-southeners.laravel-pint
      # shufo.vscode-blade-formatter
      # saeed-nazari.adonis-theme
      # formulahendry.auto-close-tag
      # formulahendry.auto-rename-tag
      # ms-vscode.azure-repos
      # github.remotehub
      # github.github-vscode-theme
      # jnoortheen.nix-ide
      # ms-vscode-remote.remote-ssh
      # ms-vscode-remote.remote-ssh-edit
      # ms-vscode.remote-explorer
      # ms-vscode.remote-repositories
    ];

    userSettings = {
      "window.commandCenter" = true;
      # "window.titleBarStyle" = "native";
      "window.customTitleBarVisibility" = "auto";
      "window.density.editorTabHeight" = "compact";

      "workbench.colorTheme" = "GitHub Dark Default";
      "workbench.activityBar.location" = "hidden";
      "workbench.statusBar.visible" = true;
      "workbench.editor.editorActionsLocation" = "hidden";
      "workbench.editor.empty.hint" = "hidden";
      "workbench.list.smoothScrolling" = true;
      "workbench.editor.tabSizing" = "shrink";
      "workbench.editor.showIcons" = true;
      # "workbench.editor.showTabs" = "single"; # Показывает только одну вкладку редактора
      # "workbench.iconTheme" = "material-icon-theme"; # Устанавливает тему иконок
      "workbench.panel.defaultLocation" = "right"; # Размещает панель справа по умолчанию
      "workbench.tree.enableStickyScroll" = true; # Включает "липкую" прокрутку в деревьях файлов
      "workbench.fontAliasing" = "antialiased"; # Устанавливает сглаживание шрифта
      "workbench.startupEditor" = "none"; # Отключает отображение редактора при запуске
      "workbench.tips.enabled" = false; # Отключает подсказки на стартовой странице
      "breadcrumbs.enabled" = false; # Отключает "хлебные крошки" в верхней части редактора
      "editor.matchBrackets" = "never"; # Отключает подсветку парных скобок
      "editor.colorDecorators" = false; # Отключает предпросмотр цвета в CSS
      # "editor.renderLineHighlight" = "none"; # Отключает подсветку текущей строки
      # "editor.occurrencesHighlight" = "off"; # Отключает выделение всех вхождений слова при фокусе
      # "problems.decorations.enabled" = false; # Отключает подсветку файлов с ошибками в эксплорере
      "editor.hideCursorInOverviewRuler" = true; # Скрывает курсор в обзорной линейке
      "window.newWindowDimensions" = "fullscreen"; # Открывает новое окно во весь экран

      # Explorer
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "explorer.compactFolders" = false;

      # Основной шрифт
      "editor.fontFamily" = "'Fira Code'; 'JetBrains Mono'; 'monospace'; monospace";
      "editor.fontSize" = 16;
      "editor.lineHeight" = 28.5;
      "editor.fontWeight" = "500";
      "editor.fontLigatures" = true;

      "editor.tabSize" = 4;
      "editor.folding" = true; # Сворачивание кода
      "editor.insertSpaces" = false; # Вставка пробелов вместо табуляции
      "editor.minimap.enabled" = false;
      "editor.detectIndentation" = true;
      "editor.suggestSelection" = "first";
      "editor.multiCursorModifier" = "alt";
      "editor.formatOnSave" = true;
      "editor.scrollBeyondLastLine" = true; # Прокрутка дальше последней строки
      "editor.linkedEditing" = true;
      "editor.renderControlCharacters" = true;
      "editor.quickSuggestionsDelay" = 0;
      "editor.bracketPairColorization.enabled" = false;
      "editor.lightbulb.enabled" = "off";
      "editor.glyphMargin" = false; # Расстояние справа от нумерации строк
      "editor.accessibilitySupport" = "off";
      "editor.wordWrap" = "off";
      "editor.padding.top" = 15;
      "editor.scrollbar.horizontal" = "auto";
      "editor.scrollbar.vertical" = "auto";
      "editor.overviewRulerBorder" = false;
      "editor.smoothScrolling" = true;
      "editor.unicodeHighlight.ambiguousCharacters" = false;
      "editor.inlineSuggest.suppressSuggestions" = true;
      "editor.renderWhitespace" = "all";
      "editor.gotoLocation.multipleDefinitions" = "goto";
      "editor.copyWithSyntaxHighlighting" = false; # Отключает копирование текста вместе с подсветкой синтаксиса
      "editor.suggestFontSize" = 15; # Устанавливает размер шрифта подсказок
      "editor.suggestLineHeight" = 30; # Устанавливает высоту строки подсказок
      "editor.stickyScroll.enabled" = true; # Включает "липкую" прокрутку
      "editor.guides.indentation" = false; # Отключает отображение вертикальных линий отступов

      "workbench.colorCustomizations" = {
        "editorWhitespace.foreground" = "#2F2F2F";
      };

      # Курсор
      "editor.cursorBlinking" = "expand";
      "editor.cursorStyle" = "line-thin";
      "editor.cursorSmoothCaretAnimation" = "explicit";

      # Терминал
      "terminal.integrated.fontFamily" = "'Fira Code'; 'JetBrains Mono'; 'monospace'; monospace";

      "terminal.integrated.fontSize" = 13;
      "terminal.integrated.lineHeight" = 1.1;
      "terminal.integrated.fontWeight" = "500";

      "terminal.integrated.smoothScrolling" = true;
      "terminal.integrated.cursorStyle" = "block";
      "terminal.integrated.cursorBlinking" = true;
      "terminal.integrated.defaultProfile.linux" = "bash";

      # Default Prettier Formatter
      "editor.formatOnPaste" = true;
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "prettier.useTabs" = true;
      "prettier.semi" = false;
      "prettier.jsxSingleQuote" = true;
      "prettier.singleQuote" = true;
      "prettier.arrowParens" = "avoid";

      # HTML
      "html.format.enable" = true;
      "html.format.wrapLineLength" = 0;
      "html.autoClosingTags" = true;
      "html.completion.attributeDefaultValue" = "singlequotes";

      # Blade
      "blade.format.enable" = true;
      "bladeFormatter.format.useTabs" = true;
      "bladeFormatter.format.noSingleQuote" = false;
      "bladeFormatter.format.noMultipleEmptyLines" = true;
      "bladeFormatter.format.wrapAttributes" = "force-expand-multiline";
      "bladeFormatter.format.wrapLineLength" = 9999999999;
      "bladeFormatter.format.wrapAttributesMinAttrs" = 4;
      "bladeFormatter.format.indentSize" = 1;
      "bladeFormatter.format.indentInnerHtml" = true;
      "bladeFormatter.format.customHtmlAttributesOrder" = "href; type; name; id; class"; # Устанавливает порядок атрибутов HTML
      "bladeFormatter.format.sortHtmlAttributes" = "custom"; # Использует пользовательский порядок атрибутов HTML
      "emmet.includeLanguages" = {
        "blade" = "html"; # Включает поддержку Emmet для Blade
        "vue-html" = "html"; # Включает поддержку Emmet для Vue HTML
        "vue" = "html"; # Включает поддержку Emmet для Vue
      };
      "[blade]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "shufo.vscode-blade-formatter";
      };

      # CSS
      "css.format.enable" = true;
      "css.format.spaceAroundSelectorSeparator" = true;
      "[css]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      # SCSS
      "scss.format.enable" = true;
      "scss.format.spaceAroundSelectorSeparator" = true;
      "[scss]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      # JSON
      "json.format.enable" = true;
      "json.format.keepLines" = true;
      "[json]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      # JavaScript
      "javascript.format.enable" = true;
      "javascript.format.placeOpenBraceOnNewLineForFunctions" = true;
      "javascript.format.placeOpenBraceOnNewLineForControlBlocks" = true;
      "javascript.format.insertSpaceBeforeFunctionParenthesis" = true;
      "javascript.format.insertSpaceAfterTypeAssertion" = true;
      "javascript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis" = true;
      "javascript.format.insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces" = true;
      "javascript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets" = true;
      "javascript.format.insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces" = true;
      "javascript.format.insertSpaceAfterConstructor" = true;
      "javascript.preferences.quoteStyle" = "single";
      "javascript.autoClosingTags" = true;
      "[javascript]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      # TypeScript
      "typescript.format.enable" = true;
      "typescript.format.placeOpenBraceOnNewLineForFunctions" = true;
      "typescript.format.placeOpenBraceOnNewLineForControlBlocks" = true;
      "typescript.format.insertSpaceBeforeFunctionParenthesis" = true;
      "typescript.format.insertSpaceAfterTypeAssertion" = true;
      "typescript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis" = true;
      "typescript.format.insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces" = true;
      "typescript.format.insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets" = true;
      "typescript.format.insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces" = true;
      "typescript.format.insertSpaceAfterConstructor" = true;
      "typescript.preferences.quoteStyle" = "single";
      "typescript.autoClosingTags" = true;
      "[typescript]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[nix]" = {
        "editor.defaultFormatter" = "kamadorueda.alejandra";
        "editor.formatOnPaste" = true;
        "editor.formatOnSave" = true;
        "editor.formatOnType" = false;
      };
      "alejandra.program" = "alejandra";

      "laravel-pint.enable" = true;
      "laravel-pint.enableDebugLogs" = true;
      "laravel-pint.executablePath" = "./vendor/bin/pint";
      "[php]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "open-southeners.laravel-pint"; # Устанавливает Laravel Pint как форматтер для PHP
        # "editor.defaultFormatter" = "bmewburn.vscode-intelephense-client";
      };
      "intelephense.format.enable" = false; # Отключает форматирование Intelephense
      "intelephense.references.exclude" = []; # Не исключает ничего из поиска ссылок Intelephense
      "Laravel.translation.diagnostics" = false; # Отключает диагностику переводов Laravel
      "namespaceResolver.sortAlphabetically" = true; # Сортирует импорты по алфавиту
      "namespaceResolver.sortOnSave" = true; # Сортирует импорты при сохранении
      "namespaceResolver.showMessageOnStatusBar" = true; # Чтобы не доставало уведомление о том; что нечего сортировать

      # GIT
      # "git.confirmSync" = false; # Отключает подтверждение при синхронизации Git
      # "git.enableSmartCommit" = true; # Включает умный коммит в Git
      # "git.decorations.enabled" = false; # Отключает подсветку измененных файлов в эксплорере
      # "git.openRepositoryInParentFolders" = "never"; # Не открывает репозиторий в родительских папках
      # "gitlens.currentLine.format" = "${author; }${agoOrDate}${' via 'pullRequest}"; # Формат информации GitLens в текущей строке
      # "gitlens.currentLine.pullRequests.enabled" = false; # Отключает информацию о пулл-реквестах в текущей строке
      # "gitlens.codeLens.enabled" = false; # Отключает CodeLens GitLens
      # "gitlens.statusBar.enabled" = false; # Отключает информацию GitLens в строке состояния
      # "gitlens.hovers.annotations.over" = "annotation"; # Показывает аннотации только при наведении на аннотацию
      # "gitlens.currentLine.enabled" = false; # Отключает информацию GitLens в текущей строке
      # "scm.diffDecorations" = "none"; # Отключает декорации diff в системе контроля версий

      "files.associations" = {
        ".blade.php" = "blade";
        ".tpl" = "html";
      };
      "workbench.layoutControl.enabled" = false;
    };
  };
}