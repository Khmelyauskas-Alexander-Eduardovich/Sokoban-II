import QtQuick 2.12
import QtQuick.Controls 2.12
import "ThemeManager.js" as Theme

Page {
    id: settingsPage
    background: Rectangle { color: "transparent" }

    header: ToolBar {
        background: Rectangle { color: "transparent" }
        Button {
            id: backward_Button_I
            text: qsTr("← Back")
            onClicked: mainStack.pop()
            flat: true
            contentItem: Text {
                text: backward_Button_I.text
                color: Theme.getTextColor()
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        clip: true

        Column {
            width: parent.width * 0.8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 25
            topPadding: 20

            Label {
                text: qsTr("Settings")
                font.pixelSize: 32; font.bold: true
                color: Theme.getTextColor()
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // --- Блок Темы ---
            Column {
                width: parent.width
                spacing: 10
                Label {
                    text: qsTr("Interface Theme:")
                    color: Theme.getTextColor()
                    font.pixelSize: 18
                }
                ComboBox {
                    width: parent.width
                    model: ["classicos", "terminal", "dos", "au_console", "tron", "green_pitch", "UBports Mania"]
                    currentIndex: model.indexOf(window.activeTheme)
                    onActivated: {
                        window.activeTheme = model[index];
                        // Нам не нужно вызывать dbManager.saveAllSettings(),
                        // потому что в main.qml стоит onActiveThemeChanged: dbManager.saveAllSettings()
                    }
                }
            }

            // --- Блок Визуалов ---
            Label {
                text: qsTr("Visuals")
                font.pixelSize: 24; font.bold: true
                color: Theme.getTextColor()
            }

            // Настройка анимации
            Row {
                width: parent.width
                spacing: 20
                Label {
                    text: qsTr("Menu Animation")
                    font.pixelSize: 18
                    color: Theme.getTextColor()
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - swAnim.width - 20
                }
                Switch {
                    id: swAnim
                    checked: window.showMenuAnimation
                    onToggled: window.showMenuAnimation = checked
                }
            }

            // Настройка лога
            Row {
                width: parent.width
                spacing: 20
                Label {
                    text: qsTr("Show Log (Debug)")
                    font.pixelSize: 18
                    color: Theme.getTextColor()
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - swLog.width - 20
                }
                Switch {
                    id: swLog
                    checked: window.showLog
                    onToggled: window.showLog = checked
                }
            }

            // Полноэкранный режим
            Row {
                width: parent.width
                spacing: 20
                Label {
                    text: qsTr("Fullscreen Mode")
                    font.pixelSize: 18
                    color: Theme.getTextColor()
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - swFull.width - 20
                }
                Switch {
                    id: swFull
                    checked: window.fullscreenMode
                    onToggled: window.fullscreenMode = checked
                }
            }
            Row {
                spacing: 20
                Label {
                    text: qsTr("Show Radar")
                    font.pixelSize: 18
                    color: Theme.getTextColor()
                }
                Switch {
                    id: radarSwitch
                    checked: window.showRadar
                    onCheckedChanged: window.showRadar = checked
                }
            }
        }
    }
}
