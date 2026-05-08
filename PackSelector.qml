import QtQuick 2.12
import QtQuick.Controls 2.12
import "LevelData.js" as LevelData
import "ThemeManager.js" as Theme

Page {
    background: Rectangle { color: "transparent" }
    header: ToolBar {
        background: Rectangle { color: "transparent" }
        Button {id: menuButton_I; text: qsTr("← Menu"); onClicked: mainStack.pop(); contentItem: Text {text: menuButton_I.text; color: Theme.getTextColor(); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight} background: Rectangle {color: "transparent"; border.width: 1; border.color: Theme.getTextColor()} }
    }

    GridView {
            id: packsGrid
            anchors.fill: parent
            anchors.margins: 20
            cellWidth: 220
            cellHeight: 160

            // ВАЖНО: используем LevelData.collections напрямую
            model: LevelData.collections

            delegate: Button {
                width: 200
                height: 140

                contentItem: Column {
                    spacing: 5
                    anchors.centerIn: parent
                    Text {
                        text: modelData.name
                        font.bold: true
                        color: Theme.getTextColor() //window.activeTheme === "tron" ? "#00FFFF" : "black"
                        horizontalAlignment: Text.AlignHCenter
                        width: 180
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        text: modelData.count + " " + qsTr("Levels")
                        color: Theme.getTextColor() //window.activeTheme === "tron" ? "#00FFFF" : "gray"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                background: Rectangle {
                    color: parent.down ? "#3300FFFF" : "transparent"
                    border.color: Theme.getTextColor() //window.activeTheme === "tron" ? "#00FFFF" : "#CCC"
                    border.width: 2
                    radius: 10
                }

                onClicked: {
                    console.log("Attempting to load pack: " + modelData.file);

                    // 1. Сначала пытаемся загрузить сам JS файл с уровнями
                    if (LevelData.loadPack(modelData.file)) {
                        // Устанавливаем имя текущего пака для БД
                        window.currentPackName = modelData.file;

                        // 2. Узнаем, какой уровень последний пройденный
                        // Используем функцию, которую мы добавили в dbManager
                        var savedIdx = dbManager.getSavedLevelForPack(window.currentPackName);

                        // Устанавливаем индекс (либо сохраненный, либо 0, если пак новый)
                        window.currentLevelIdx = savedIdx;

                        console.log("Progress found! Starting from level: " + window.currentLevelIdx);

                        // 3. Грузим именно этот уровень и летим в игру
                        engine.loadLevel(window.currentLevelIdx, false);
                        mainStack.push("GameView.qml");

                    } else {
                        console.log("F*ck! Still not loading " + modelData.file);
                    }
                }
            }
        }
}
