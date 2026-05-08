import QtQuick 2.12
import QtQuick.Controls 2.12
import "ThemeManager.js" as Theme
import "LevelData.js" as LevelData

Page {
    id: packSelector
    background: Rectangle { color: "transparent" }

    header: ToolBar {
        background: Rectangle { color: "transparent" }
        Button {
            text: qsTr("← Back")
            onClicked: mainStack.pop()
            flat: true
            contentItem: Text {
                text: parent.text
                color: Theme.getTextColor()
                font.bold: true
            }
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Label {
            text: qsTr("Select Level Pack")
            font.pixelSize: 28; font.bold: true
            color: Theme.getTextColor()
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ListView {
            id: packList
            width: parent.width
            height: parent.height - 60
            model: LevelData.collections
            spacing: 10
            clip: true

            delegate: ItemDelegate {
                width: packList.width
                height: 100

                background: Rectangle {
                    color: window.activeTheme === "green_pitch" || window.activeTheme === "terminal" ? "#111" : "#eee"
                    radius: 10
                    border.color: highlighted ? Theme.getTextColor() : "transparent"
                    border.width: 2
                    opacity: hovered ? 0.9 : 0.7
                }

                contentItem: Row {
                    spacing: 15
                    anchors.fill: parent
                    anchors.margins: 10

                    // Иконка или просто порядковый номер
                    Rectangle {
                        width: 50; height: 50
                        radius: 25
                        color: Theme.getTextColor()
                        opacity: 0.2
                        anchors.verticalCenter: parent.verticalCenter
                        clip: true
                        Text {
                            anchors.centerIn: parent
                            text: modelData.name[0] // Первая буква названия
                            color: Theme.getTextColor()
                            font.bold: true
                        }
                        /*Image {
                            id: icon_of_pack
                            source: modelData.icon
                            anchors.fill: parent
                        }*/
                    }

                    Column {
                        width: parent.width - 70
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            text: modelData.name
                            font.pixelSize: 18; font.bold: true
                            color: Theme.getTextColor()
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        Label {
                            text: modelData.author
                            font.pixelSize: 15; font.bold: false
                            font.italic: true
                            color: Theme.getTextColor()
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        Label {
                            text: modelData.description + " (" + (modelData.count || "??") + " levels)"
                            font.pixelSize: 13
                            color: Theme.getTextColor()
                            opacity: 0.7
                        }
                    }
                }

                onClicked: {
                    // ГЛАВНЫЙ ФИКС: Вызываем новую умную функцию из main.qml
                    dbManager.loadPackAndLevel(modelData.file);
                    mainStack.push("GameView.qml");
                    console.log("SUCCESS: Switching to pack " + modelData.file);
                }
            }
        }
    }
}
