import QtQuick 2.12
import QtQuick.Controls 2.12
import "ThemeManager.js" as Theme

Page {
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
                color: Theme.getTextColor();
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 20

        Label {
            text: qsTr("Settings")
            font.pixelSize: 28; font.bold: true
            color: Theme.getTextColor()
        }

        Row {
            spacing: 10
            Label { text: qsTr("Theme:"); anchors.verticalCenter: parent.verticalCenter; color: Theme.getTextColor() }
            ComboBox {
                model: ["classicos", "terminal", "dos", "au_console", "tron"]
                currentIndex: model.indexOf(window.activeTheme)
                onActivated: {
                    var themeKey = model[index]; // Берем ключ темы
                    window.activeTheme = themeKey;
                    Theme.setTheme(themeKey);
                    dbManager.saveTheme(themeKey); // Сохраняем в SQLite
                    console.log("Theme saved: " + themeKey);
                }
            }
        }
                    Label {
                        text: qsTr("Visuals")
                        font.pixelSize: 22; font.bold: true
                        color: Theme.getTextColor()
                    }

                    Rectangle {
                        width: parent.width; height: 20
                        color: "transparent"
                        radius: 2
                        border.color: "transparent" //window.activeTheme === "tron" ? "#00FFFF" : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 20

                            Label {
                                text: qsTr("Menu Background Animation")
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 16
                                color: Theme.getTextColor()
                            }

                            Switch {
                                id: animSwitch
                                anchors.verticalCenter: parent.verticalCenter
                                // Привязываем к нашей переменной из main.qml
                                checked: window.showMenuAnimation

                                onToggled: {
                                    window.showMenuAnimation = checked
                                    // Вызываем сохранение в базу, которое мы прописали в main.qml
                                    if (typeof window.saveSettings === "function") {
                                        window.saveSettings()
                                    }
                                    console.log("Animation is now: " + (checked ? "ON" : "OFF"))
                                }
                            }
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: 20
                        color: "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 20

                            Label {
                                text: qsTr("Log text (Desktop)")
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 16
                                color: Theme.getTextColor()
                            }

                            Switch {
                                id: logText_switch
                                anchors.verticalCenter: parent.verticalCenter
                                // Привязываем к нашей переменной из main.qml
                                checked: window.showLog

                                onToggled: {
                                    window.showLog = checked
                                    dbManager.saveSettings() // Вызываем через dbManager!
                                }
                            }
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: 20
                        color: "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 20

                            Label {
                                text: qsTr("Fullscreen Mode")
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 16
                                color: Theme.getTextColor()
                            }

                            Switch {
                                id: fullscreen_switch
                                anchors.verticalCenter: parent.verticalCenter
                                // Привязываем к нашей переменной из main.qml
                                checked: window.fullscreenMode

                                onToggled: {
                                    window.fullscreenMode = checked
                                    // Вызываем сохранение в базу, которое мы прописали в main.qml
                                    if (typeof window.saveSettings === "function") {
                                        window.saveSettings()
                                    }
                                    window.fullscreenMode = checked
                                }
                            }
                        }
                    }
                }
    }
