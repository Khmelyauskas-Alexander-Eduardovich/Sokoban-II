import QtQuick 2.12
import QtQuick.Controls 2.12
import "ThemeManager.js" as Theme

Page {
    id: mainMenu
    background: Rectangle { color: window.color }

    Item {
        id: backgroundAnimation
        anchors.fill: parent
        visible: !!window.showMenuAnimation

        Repeater {
            model: 15
            Image {
                id: fallingAsset
                property int delay: Math.random() * 5000
                property int duration: Math.random() * 4000 + 4000

                width: 40; height: 40; opacity: 0.15
                x: Math.random() * parent.width
                y: parent.height + 100

                // Проверь регистр папки Assets и подпапок!
                source: {
                    // Список ключей вручную на случай, если JS еще не прогрузился полностью
                    var fallbackKeys = ["tron", "classicos", "terminal", "au_console", "dos"];
                    var keys = (typeof Theme.getThemeKeys === "function") ? Theme.getThemeKeys() : fallbackKeys;

                    var assets = ["wall", "box", "player", "goal"];
                    var randomTheme = keys[Math.floor(Math.random() * keys.length)];
                    var randomAsset = assets[Math.floor(Math.random() * assets.length)];

                    // Сохраняем текущую тему, чтобы не сбить её во время генерации пути
                    var oldKey = Theme.currentThemeKey;
                    Theme.setTheme(randomTheme);
                    var path = "qrc:/" + Theme.getUrl(randomAsset);
                    Theme.setTheme(oldKey);

                    return path;
                }

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    running: true // Запускаем сразу

                    // Сначала ставим в начальную точку БЕЗ анимации
                    PropertyAction { target: fallingAsset; property: "y"; value: parent.height + 60 }

                    PauseAnimation { duration: fallingAsset.delay }

                    NumberAnimation {
                        from: parent.height + 60
                        to: -100
                        duration: fallingAsset.duration
                        easing.type: Easing.OutCubic
                    }
                }

                RotationAnimation on rotation {
                    from: 0; to: 360; duration: 8000; loops: Animation.Infinite
                }
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 15
        Text {
            text: qsTr("SOKOBAN II") // Не забыл про qsTr!
            font.pixelSize: 42; font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            // Привязываемся к свойству окна, чтобы цвет обновился мгновенно
            color: window.activeTheme ? Theme.getTextColor() : "#32CD32"
        }
        Button { text: qsTr("Play"); width: 200; onClicked: mainStack.push("PreGameMenu.qml") }
        Button { text: qsTr("Settings"); width: 200; onClicked: mainStack.push("SettingsPage.qml") }
        Button { text: qsTr("Quit!"); width: 200; onClicked: Qt.quit() }
    }
}
