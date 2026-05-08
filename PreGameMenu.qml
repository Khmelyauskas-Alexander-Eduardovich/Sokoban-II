import QtQuick 2.12
import QtQuick.Controls 2.12
import "ThemeManager.js" as Theme

Page {
    id: preGameMenu
    background: Rectangle { color: "transparent" }

    Column {
        anchors.centerIn: parent
        spacing: 30

        Label {
            text: qsTr("Continue Adventure?")
            font.pixelSize: 32; font.bold: true
            color: Theme.getTextColor()
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Кнопка продолжения (последний пак и уровень уже подтянуты в main.qml)
        Button {
            id: continueBtn
            text: qsTr("CONTINUE")
            width: 250; height: 60
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                // В main.qml при старте уже отработал boot(),
                // так что индекс и пак уже стоят правильные.
                // Просто заходим в игру!
                mainStack.push("GameView.qml")
            }
        }

        Button {
            text: qsTr("SELECT PACK")
            width: 250; height: 60
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: mainStack.push("PackSelector.qml")
        }

        Button {
            text: qsTr("MAIN MENU")
            width: 250; height: 60
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: mainStack.pop()
        }
    }

    // Небольшая подсказка снизу, что именно мы продолжаем
    Label {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        text: qsTr("Current Pack: %1 (Level %2)")
                .arg(window.currentPackName.replace(".js", "").replace("levels_", ""))
                .arg(window.currentLevelIdx + 1)
        color: Theme.getTextColor()
        opacity: 0.6
        font.pixelSize: 14
    }
}
