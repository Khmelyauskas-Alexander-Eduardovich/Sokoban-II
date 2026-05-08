QT += quick qml sql core gui quickcontrols2

CONFIG += c++11
SOURCES += main.cpp

# Если ты используешь INSTALLS для QML и JS, убери qml.qrc из RESOURCES,
# либо оставь только те файлы, которые реально зашиты.
# Но для UT надежнее работать через файловую систему.
RESOURCES += qml.qrc

# --- Распространяемые файлы (DISTFILES) ---
# Сюда пишем всё, что Qt Creator должен "видеть" в дереве проекта
DISTFILES += \
    Assets/Interesting Terminal/player_on_goal.svg \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml \
    manifest.json \
    sokoban2.desktop \
    sokoban2.apparmor \
    *.qml \
    *.js \
    Assets/**/* \
    "Level Packs"/*.js

# --- ПРАВИЛА УСТАНОВКИ (INSTALLS) ---
# Clickable берет файлы из этих путей для создания .click пакета

target.path = /
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
    translations/base_ru.ts \
    translations/base_tg.ts \
    translations/base_nl.ts \
    translations/base_ar.ts \
    translations/base_ca.ts \
    translations/base_eu.ts \
    translations/base_ja.ts \
    translations/base_es.ts \
    translations/base_en.ts

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
