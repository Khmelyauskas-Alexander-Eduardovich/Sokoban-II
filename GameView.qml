import QtQuick 2.12
import QtQuick.Controls 2.12
import "ThemeManager.js" as Theme
import "LevelData.js" as LevelData

Page {
    id: gameView
    background: Rectangle { color: "transparent" }
    readonly property bool isLandscape: width > height
    property bool isEndOfPack: window.currentLevelIdx >= (LevelData.levels ? LevelData.levels.length - 1 : 0)
    property alias finishDialog: collectionFinishedDialog

    // Чтобы клавиатура работала сразу при входе
    Component.onCompleted: gameView.forceActiveFocus()

    // Фокус для клавиш
    focus: true

    Keys.onPressed: (event) => {
        if (engine.swipeMode) return;

        var dx = 0, dy = 0;
        var msg = "";
        var keyName = "";

        // Обработка движения
        if (event.key === Qt.Key_Up || event.key === Qt.Key_W) {
            dy = -1; msg = qsTr("Player moved up"); keyName = "Up/W";
        }
        else if (event.key === Qt.Key_Down || event.key === Qt.Key_S) {
            dy = 1; msg = qsTr("Player moved down"); keyName = "Down/S";
        }
        else if (event.key === Qt.Key_Left || event.key === Qt.Key_A) {
            dx = -1; msg = qsTr("Player moved left"); keyName = "Left/A";
        }
        else if (event.key === Qt.Key_Right || event.key === Qt.Key_D) {
            dx = 1; msg = qsTr("Player moved right"); keyName = "Right/D";
        }
        // Обработка Undo
        else if (event.key === Qt.Key_Z) {
            engine.back();
            logModel.insert(0, { "msg": qsTr("Action undone (Ctrl+Z)") });
            if (logModel.count > 10) logModel.remove(logModel.count - 1);
            return;
        }
        // Обработка Ресета
        else if (event.key === Qt.Key_R) {
            logModel.insert(0, { "msg": qsTr("Level reset (R)") });
                            // 1. Чистим историю (теперь функция существует)
                                engine.clearHistory();

                                // 2. Перезагружаем карту (чтобы ящики вернулись на старт)
                                engine.loadLevel(window.currentLevelIdx, true);
                                return;
        }

        // Если было движение - пишем детально
        if (dx !== 0 || dy !== 0) {
            var detailedMsg = msg + " [" + keyName + "]";
            logModel.insert(0, { "msg": detailedMsg });

            if (logModel.count > 10) logModel.remove(logModel.count - 1);
            engine.step(dx, dy);
        }
    }

    header: ToolBar {
        background: Rectangle { color: "transparent" }
        Row {
            spacing: 20
            width: parent.width; height: parent.height
            Button { text: qsTr("← Menu"); flat: true; onClicked: mainStack.pop() }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Label {
                    text: qsTr("Level: %1").arg(window.currentLevelIdx + 1)
                    font.pixelSize: 20; font.bold: true
                    color: Theme.getTextColor()
                }
                Text {
                    text: qsTr("End of collection! ::)")
                    color: "#FFFF00"
                    font.italic: true; font.pixelSize: 12
                    visible: isEndOfPack
                }
            }
        }
    }

    // Основной контейнер, который делит экран на Игру и Лог
    Row {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Левая часть: Игровое поле
        Item {
            id: flickViewport
            width: isLandscape ? parent.width - logPanel.width - 20 : parent.width
            height: parent.height
            clip: true

            Item {
                id: gameContainer
                width: Math.max(engine.mapW * 40, 1)
                height: Math.max((engine.currentLevelMap ? engine.currentLevelMap.length : 1) * 40, 1)
                scale: 1.0
                transformOrigin: Item.TopLeft

                Component.onCompleted: resetPosition()
                function resetPosition() {
                    x = (flickViewport.width - width) / 2
                    y = (flickViewport.height - height) / 2
                }

                GridView {
                    id: gameGrid; anchors.fill: parent; cellWidth: 40; cellHeight: 40
                    model: gameModel; interactive: false
                    delegate: Item {
                        width: 40; height: 40
                        Image {
                            anchors.fill: parent
                            smooth: Theme.isSmooth ? Theme.isSmooth() : true
                            source: "qrc:/" + Theme.getUrl(
                                model.type === "#" ? "wall" :
                                model.type === "@" ? "player" :
                                model.type === "$" ? "box" :
                                model.type === "." ? "goal" :
                                model.type === "*" ? "box_on_goal" :
                                model.type === "+" ? "player" : "floor"
                            )
                        }
                    }
                }
            }

            // Контроллер Тача и Мыши (Объединенный)
            MultiPointTouchArea {
                anchors.fill: parent
                mouseEnabled: true
                onPressed: (touchPoints) => {
                        gameView.forceActiveFocus()
                        // СРАЗУ запоминаем точку касания, чтобы дельта была 0
                        lastX = touchPoints[0].x
                        lastY = touchPoints[0].y
                    }

                property real lastX: 0
                property real lastY: 0

                onUpdated: (touchPoints) => {
                        if (touchPoints.length === 1) {
                            // Считаем разницу между текущим кадром и предыдущим
                            var dx = touchPoints[0].x - lastX
                            var dy = touchPoints[0].y - lastY

                            gameContainer.x += dx
                            gameContainer.y += dy

                            // Обновляем "предыдущую" точку
                            lastX = touchPoints[0].x
                            lastY = touchPoints[0].y
                        }
                    }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    onWheel: {
                        var delta = wheel.angleDelta.y > 0 ? 1.1 : 0.9
                        var newScale = Math.min(5.0, Math.max(0.3, gameContainer.scale * delta))
                        gameContainer.x = wheel.x - (wheel.x - gameContainer.x) * (newScale / gameContainer.scale)
                        gameContainer.y = wheel.y - (wheel.y - gameContainer.y) * (newScale / gameContainer.scale)
                        gameContainer.scale = newScale
                    }
                   // onPressed: gameView.forceActiveFocus()
                }
            }
        }

        Item {
            id: logPanel
            width: (isLandscape && window.showLog) ? 280 : 0
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
            anchors.bottomMargin: controlRoot.height + actionsBar.height + 40
            visible: width > 0
            clip: true

            ListModel { id: logModel }

            ListView {
                id: logListView
                anchors.fill: parent
                model: logModel
                spacing: 5
                interactive: false

                // Магия: прижимаем элементы к низу, чтобы новые "выталкивали" старые вверх
                verticalLayoutDirection: ListView.BottomToTop

                // Анимация для всех элементов, которые сдвигаются при удалении/добавлении
                displaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                delegate: Item {
                    id: logDelegate
                    width: logListView.width
                    height: 22

                    // Плавное появление новой строки
                    opacity: 0
                    Component.onCompleted: NumberAnimation {
                        target: logDelegate; property: "opacity"; to: 1; duration: 300
                    }

                    // Используем обычные элементы без anchors внутри Row
                    Row {
                        spacing: 8
                        height: parent.height

                        Text {
                            text: "[" + new Date().toLocaleTimeString('en-GB', { hour: '2d', minute: '2d', second: '2d' }) + "]"
                            color: "#555"
                            font.pixelSize: 10
                            font.family: "Monospace"
                            //anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: model.msg
                            color: Theme.getTextColor()
                            font.pixelSize: 11
                            font.family: "Monospace"
                            //anchors.verticalCenter: parent.verticalCenter
                            width: logDelegate.width - 70
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    // --- Слой управления (над игрой) ---
    Item {
        anchors.fill: parent
        enabled: true // Чтобы не блокировать клики по кнопкам

        Item {
            id: controlRoot
            width: 250; height: 180
            anchors.right: parent.right; anchors.bottom: actionsBar.top
            anchors.margins: 15


            Rectangle {
                id: touchpad
                anchors.fill: parent
                color: window.activeTheme === "terminal" ? "#111" : "white"
                radius: 20; border.color: "black"; border.width: 2
                opacity: engine.swipeMode ? 0.6 : 0
                visible: opacity > 0

                Text {
                    anchors.centerIn: parent;
                    text: qsTr("SWIPE MODE\nDouble tap to exit");
                    color: "white"; horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent; enabled: engine.swipeMode
                    property real sX: 0; property real sY: 0
                    onPressed: { sX = mouse.x; sY = mouse.y }
                    onPositionChanged: {
                        var dx = mouse.x - sX; var dy = mouse.y - sY
                        if (Math.abs(dx) > 40) { engine.step(dx > 0 ? 1 : -1, 0); sX = mouse.x; sY = mouse.y }
                        else if (Math.abs(dy) > 40) { engine.step(0, dy > 0 ? 1 : -1); sX = mouse.x; sY = mouse.y }
                    }
                    onDoubleClicked: engine.swipeMode = false
                }
            }

            Grid {
                columns: 3; spacing: 8; anchors.centerIn: parent
                visible: !engine.swipeMode
                Item { width: 55; height: 55 }
                Button { text: "↑"; width: 55; height: 55; onClicked: engine.step(0, -1); onPressAndHold: engine.swipeMode = true }
                Item { width: 55; height: 55 }
                Button { text: "←"; width: 55; height: 55; onClicked: engine.step(-1, 0); onPressAndHold: engine.swipeMode = true }
                Button { text: "↓"; width: 55; height: 55; onClicked: engine.step(0, 1); onPressAndHold: engine.swipeMode = true }
                Button { text: "→"; width: 55; height: 55; onClicked: engine.step(1, 0); onPressAndHold: engine.swipeMode = true }
            }
        }

        Row {
            id: actionsBar
            anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15; anchors.margins: 15
            Button { text: "⬅"; width: 60; onClicked: { if(window.currentLevelIdx > 0) engine.loadLevel(--window.currentLevelIdx, false) } }
            Button { text: "↺"; width: 60; onClicked: engine.loadLevel(window.currentLevelIdx, true) }
            Button { text: qsTr("Undo"); width: 80; onClicked: engine.back() }
            Button {
                text: qsTr("Next")
                width: 80
                enabled: !isEndOfPack
                onClicked: {
                    window.currentLevelIdx++;
                    engine.loadLevel(window.currentLevelIdx, false);
                }
            }
        }
    }

    Text {
        text: qsTr("SUCCESS!")
        visible: !!engine.winState
        anchors.centerIn: parent
        font.pixelSize: 60; font.bold: true
        color: "#34C759"; style: Text.Outline; styleColor: "black"
    }
    Dialog {
        id: collectionFinishedDialog
        title: qsTr("Collection Finished!")
        anchors.centerIn: parent
        modal: true

        // Кастомные кнопки
        standardButtons: Dialog.No | Dialog.Yes

        Component.onCompleted: {
            // Переименовываем стандартные кнопки для понту
            standardButton(Dialog.Yes).text = "Yes, I wanna"
            standardButton(Dialog.No).text = "No, I don't want"
            if (typeof LevelData.levels[window.currentLevelIdx] === "undefined") {
                    console.log("LOG: End of pack detected!");
                    collectionFinishedDialog.open();
                }
        }

        Label {
            width: parent.width
            text: qsTr("Congratulations! You've finished the pack.\nDo You wanna to reset and play again?")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: Theme.getTextColor()
        }

        onAccepted: {
            window.currentLevelIdx = 0
            engine.clearHistory()
            engine.loadLevel(0, true)
            console.log("Starting over! ::)")
        }

        onRejected: {
            mainStack.pop() // Выходим в меню, раз не хочет заново
        }
    }

}
