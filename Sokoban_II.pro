QT += quick

CONFIG += c++11
SOURCES += main.cpp

# Если ты используешь INSTALLS для QML и JS, убери qml.qrc из RESOURCES, 
# либо оставь только те файлы, которые реально зашиты. 
# Но для UT надежнее работать через файловую систему.
RESOURCES += qml.qrc 

# --- Распространяемые файлы (DISTFILES) ---
# Сюда пишем всё, что Qt Creator должен "видеть" в дереве проекта
DISTFILES += \
    manifest.json \
    sokoban2.desktop \
    sokoban2.apparmor \
    *.qml \
    *.js \
    Assets/**/* \
    "Level Packs"/*.js

# --- ПРАВИЛА УСТАНОВКИ (INSTALLS) ---
# Clickable берет файлы из этих путей для создания .click пакета

target.path = /lib
INSTALLS += target

# Манифест, Desktop-файл и Apparmor в корень
ut_metadata.path = /
ut_metadata.files = manifest.json sokoban2.desktop sokoban2.apparmor
INSTALLS += ut_metadata

# Все QML файлы в корень
qml_files.path = /
qml_files.files = main.qml MainMenu.qml PackSelector.qml SettingsPage.qml GameView.qml
INSTALLS += qml_files

# Все JS файлы в корень (не забудь LevelParser.js, если он нужен)
javascript_files.path = /
javascript_files.files = GameLogic.js LevelData.js LevelParser.js ThemeManager.js
INSTALLS += javascript_files

# Ассеты (Иконки, Сплэши и папки тем)
# Используем селектор *, чтобы не перечислять каждый файл
assets_files.path = /Assets
assets_files.files = Assets/*
INSTALLS += assets_files

# Уровни (Level Packs)
# Кавычки нужны, если в названии папки есть пробел!
js_levels.path = /Level\ Packs
js_levels.files = "Level Packs"/*.js
INSTALLS += js_levels

# Переводы
translations.path = /translations
translations.files = translations/*.qm
INSTALLS += translations

TRANSLATIONS += \
    translations/ru.ts \
    translations/tg.ts \
    translations/nl.ts \
    translations/ar.ts \
    translations/ca.ts \
    translations/eu.ts \
    translations/ja.ts \
    translations/es.ts \
    translations/en.ts
