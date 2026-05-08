import QtQuick 2.12
import QtQuick.Controls 2.12

Page {
    background: Rectangle { color: window.color }

    Column {
        anchors.centerIn: parent
        spacing: 20

        Button {
            text: "CONTINUE"
            width: 250; height: 60
            onClicked: {
                // Тут в будущем прикрутим загрузку последнего пака/уровня
                mainStack.push("PackSelector.qml")
            }
        }

        Button {
            text: "NEW GAME"
            width: 250; height: 60
            onClicked: {
                window.currentLevelIdx = 0
                mainStack.push("PackSelector.qml")
            }
        }

        Button {
            text: "BACK"
            flat: true
            onClicked: mainStack.pop()
        }
    }
}
