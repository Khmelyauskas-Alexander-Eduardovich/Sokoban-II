import QtQuick 2.12
import QtQuick.Controls 2.12
import "ThemeManager.js" as Theme
import "LevelData.js" as LevelData

Page {
    id: gameView
    background: Rectangle { color: "transparent" }

    readonly property bool isLandscape: width > height
    property alias finishDialog: collectionFinishedDialog
    readonly property color currentThemeColor: Theme.getTextColor()
    property int controlMode: 0

    // Безопасная проверка конца пака
    property bool isEndOfPack: {
        if (!LevelData.levels || LevelData.levels.length === 0) return true;
        return window.currentLevelIdx >= LevelData.levels.length - 1;
    }

    // При входе принудительно берем фокус и проверяем, загружена ли карта
    Component.onCompleted: {
        gameView.forceActiveFocus();
        // Если по какой-то причине карта не подтянулась, грузим её
        if (engine.currentLevelMap.length === 0) {
            engine.loadLevel(window.currentLevelIdx, false);
        }
    }

    focus: true

    Keys.onPressed: (event) => {
        if (engine.swipeMode) return;

        var dx = 0, dy = 0;
        var msg = "";

        if (event.key === Qt.Key_Up || event.key === Qt.Key_W) { dy = -1; msg = qsTr("Up"); }
        else if (event.key === Qt.Key_Down || event.key === Qt.Key_S) { dy = 1; msg = qsTr("Down"); }
        else if (event.key === Qt.Key_Left || event.key === Qt.Key_A) { dx = -1; msg = qsTr("Left"); }
        else if (event.key === Qt.Key_Right || event.key === Qt.Key_D) { dx = 1; msg = qsTr("Right"); }
        else if (event.key === Qt.Key_Z) {
            engine.back();
            addLog(qsTr("Undo action"));
            return;
        }
        else if (event.key === Qt.Key_R) {
            addLog(qsTr("Level reset"));
            engine.loadLevel(window.currentLevelIdx, true); // loadLevel сам всё почистит
            return;
        }
        else if (event.key === Qt.Key_Escape) { window.fullscreenMode = false; return; }
        else if (event.key === Qt.Key_F) { window.fullscreenMode = true; return; }

        if (dx !== 0 || dy !== 0) {
            addLog(qsTr("Move %1").arg(msg));
            engine.step(dx, dy);
        }
    }

    function addLog(message) {
        // Проверка на существование модели, чтобы наверняка
        if (!window.showLog || typeof logModel === "undefined") return;
        logModel.insert(0, { "msg": message });
        if (logModel.count > 10) logModel.remove(logModel.count - 1);
    }

    header: ToolBar {
        background: Rectangle { color: "transparent" }
        Row {
            spacing: 20; anchors.fill: parent; anchors.leftMargin: 10
            Button {
                text: qsTr("← Menu"); flat: true;
                onClicked: mainStack.pop();
                contentItem: Text { text: parent.text; color: Theme.getTextColor(); font.bold: true }
            }
            Item {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Label {
                    id: level_label
                    text: qsTr("Level: %1").arg(window.currentLevelIdx + 1)
                    font.pixelSize: 20; font.bold: true; color: Theme.getTextColor()
                }
                Text {
                    text: qsTr("End of collection! ::)")
                    color: "#FFFF00"; font.italic: true; font.pixelSize: 12
                    visible: isEndOfPack
                    anchors.top: level_label.bottom
                    anchors.margins: 5
                }
            }
        }
    }

    // Игровое поле
    Item {
        id: flickViewport
        width: (isLandscape && window.showLog) ? parent.width - logPanel.width - 20 : parent.width
        height: parent.height; clip: true

        Item {
            id: gameContainer
            width: Math.max(engine.mapW * 40, 1)
            height: Math.max((engine.currentLevelMap ? engine.currentLevelMap.length : 1) * 40, 1)
            x: (flickViewport.width - width) / 2
            y: (flickViewport.height - height) / 2
            scale: 1.0; transformOrigin: Item.TopLeft

            GridView {
                id: gameGrid; anchors.fill: parent; cellWidth: 40; cellHeight: 40
                model: gameModel; interactive: false
                delegate: Item {
                    width: 40; height: 40

                    // Фоновая плитка — всегда одна и без сглаживания
                    Image {
                        anchors.fill: parent
                        source: "qrc:/" + Theme.getUrl("floor")
                        sourceSize: "40x40"
                        smooth: false
                        asynchronous: true
                    }

                    // Основной объект (стена, игрок, ящик)
                    Image {
                        anchors.fill: parent
                        z: 1
                        smooth: true
                        asynchronous: true
                        sourceSize: "40x40"

                        // Одно условие вместо кучи Image
                        source: {
                            let t = model.type
                            if (t === ".") return "qrc:/" + Theme.getUrl("goal")
                            if (t === "#") return "qrc:/" + Theme.getUrl("wall")
                            if (t === "$") return "qrc:/" + Theme.getUrl("box")
                            if (t === "*") return "qrc:/" + Theme.getUrl("box_on_goal")
                            if (t === "@") return "qrc:/" + Theme.getUrl("player")
                            if (t === "+") return "qrc:/" + Theme.getUrl("player_on_goal")
                            return ""
                        }
                    }
                }
            }
        }

        MultiPointTouchArea {
            anchors.fill: parent
            touchPoints: [
                TouchPoint { id: tp1 },
                TouchPoint { id: tp2 }
            ]

            property real lastX
            property real lastY
            property real initialDist
            property real initialScale

            onPressed: (touchPoints) => {
                gameView.forceActiveFocus()
                if (touchPoints.length === 1) {
                    lastX = touchPoints[0].x
                    lastY = touchPoints[0].y
                } else if (touchPoints.length === 2) {
                    // Считаем начальное расстояние между двумя пальцами
                    let dx = tp1.x - tp2.x
                    let dy = tp1.y - tp2.y
                    initialDist = Math.sqrt(dx*dx + dy*dy)
                    initialScale = gameContainer.scale
                }
            }

            onUpdated: (touchPoints) => {
                if (touchPoints.length === 1 && !tp2.pressed) {
                    // ФЛИК: Работает только если второй палец не нажат
                    let p = touchPoints[0]
                    let dx = p.x - lastX
                    let dy = p.y - lastY
                    gameContainer.x += dx
                    gameContainer.y += dy
                    lastX = p.x
                    lastY = p.y
                }
                else if (tp1.pressed && tp2.pressed) {
                    // ЗУМ: Когда нажаты оба (tp1 и tp2)
                    let dx = tp1.x - tp2.x
                    let dy = tp1.y - tp2.y
                    let dist = Math.sqrt(dx*dx + dy*dy)

                    if (initialDist > 0) {
                        let newScale = Math.min(5.0, Math.max(0.3, initialScale * (dist / initialDist)))
                        let ratio = newScale / gameContainer.scale

                        // Точка, относительно которой зумим (центр между пальцами)
                        let cx = (tp1.x + tp2.x) / 2
                        let cy = (tp1.y + tp2.y) / 2

                        gameContainer.x = cx - (cx - gameContainer.x) * ratio
                        gameContainer.y = cy - (cy - gameContainer.y) * ratio
                        gameContainer.scale = newScale
                    }
                }
            }
        }
        MouseArea {
            anchors.fill: parent; acceptedButtons: Qt.NoButton
            onWheel: {
                let delta = wheel.angleDelta.y > 0 ? 1.1 : 0.9
                let newScale = Math.min(5.0, Math.max(0.3, gameContainer.scale * delta))
                let ratio = newScale / gameContainer.scale
                gameContainer.x = wheel.x - (wheel.x - gameContainer.x) * ratio
                gameContainer.y = wheel.y - (wheel.y - gameContainer.y) * ratio
                gameContainer.scale = newScale
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

    // Контроллеры
    Item {
        id: controlRoot
        width: 250; height: 180;
        anchors.bottom: actionsBar.top
                anchors.right: isLandscape ? parent.right : undefined
                anchors.horizontalCenter: isLandscape ? undefined : parent.horizontalCenter
                anchors.margins: 5
        enabled: true
        Rectangle {
            id: touchpad
            anchors.fill: parent
            color: "grey"
            radius: 20; border.color: Theme.getTextColor(); border.width: 2
            opacity: controlMode === 1 ? 0.3 : 0
                visible: opacity > 0 // Элемент исчезает из дерева отрисовки только когда прозрачность в нуле
                scale: controlMode === 1 ? 1 : 0.8 // Чуть уменьшаем, когда скрыт

                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } } // Эффект прыжка
            Text {
                anchors.centerIn: parent;
                text: qsTr("SWIPE MODE\nDouble tap to exit");
                color: "white"; horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent; enabled: controlMode === 1
                property real sX: 0; property real sY: 0
                onPressed: { sX = mouse.x; sY = mouse.y }
                onPositionChanged: {
                    var dx = mouse.x - sX; var dy = mouse.y - sY
                    if (Math.abs(dx) > 40) { engine.step(dx > 0 ? 1 : -1, 0); sX = mouse.x; sY = mouse.y }
                    else if (Math.abs(dy) > 40) { engine.step(0, dy > 0 ? 1 : -1); sX = mouse.x; sY = mouse.y }
                }
                onDoubleClicked: controlMode = 0
            }
        }

        // Кнопки управления (стрелки)
        Grid {
            columns: 3; spacing: 8; anchors.centerIn: parent
            opacity: controlMode === 0 ? 1 : 0
                visible: opacity > 0
                scale: controlMode === 0 ? 1 : 0.5
            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }
            Item { width: 55; height: 55 }
            Button { text: "↑"; width: 55; height: 55; onClicked: engine.step(0, -1); onPressAndHold: controlMode = 2 }
            Item { width: 55; height: 55 }
            Button { text: "←"; width: 55; height: 55; onClicked: engine.step(-1, 0); onPressAndHold: controlMode = 2}
            Button { text: "↓"; width: 55; height: 55; onClicked: engine.step(0, 1); onPressAndHold: controlMode = 2 }
            Button { text: "→"; width: 55; height: 55; onClicked: engine.step(1, 0); onPressAndHold: controlMode = 2 }
        }
        Joystick {
                id: staticJoystick
                anchors.centerIn: parent
                opacity: controlMode === 2 ? 1 : 0
                    visible: opacity > 0
                    scale: controlMode === 2 ? 1 : 1.5 // Пусть он как бы "схлопывается" при исчезновении

                    Behavior on opacity { NumberAnimation { duration: 250 } }
                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                onMove: (dx, dy) => {
                    engine.step(dx, dy) // Двигаем игрока
                }

                onDoubleClick: {
                    controlMode = 1
                }
            }
    }
    Row {
        id: actionsBar
        spacing: 10; anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.margins: 20
        Button {
            text: "⬅";
            width: 60;
            onClicked: {
                if(window.currentLevelIdx > 0) {
                    window.currentLevelIdx--; // Уменьшаем индекс!
                    engine.loadLevel(window.currentLevelIdx, false);
                }
            }
        }
        Button { text: "↺"; width: 60; onClicked: engine.loadLevel(window.currentLevelIdx, true) }
        Button { text: qsTr("Undo"); width: 80; onClicked: engine.back() }
        Button {
            text: qsTr("Next"); width: 80; enabled: window.currentLevelIdx < LevelData.levels.length - 1
            onClicked: { window.currentLevelIdx++; engine.loadLevel(window.currentLevelIdx, true); }
        }
    }

    // Текст победы
    Text {
        text: qsTr("SUCCESS!")
        // ВАЖНО: вызываем функцию isWin() из движка
        visible: typeof engine.isWin === "function" ? engine.isWin() : false
        anchors.centerIn: parent
        font.pixelSize: 60; font.bold: true
        color: "#34C759"; style: Text.Outline; styleColor: "black"
    }

    // Диалог завершения коллекции
    Dialog {
        id: collectionFinishedDialog
        title: qsTr("Collection Finished!")
        anchors.centerIn: parent; modal: true
        standardButtons: Dialog.No | Dialog.Yes
        Label {
            text: qsTr("Congratulations! Play again from the start?")
            color: Theme.getTextColor(); horizontalAlignment: Text.AlignHCenter
        }
        onAccepted: { window.currentLevelIdx = 0; engine.loadLevel(0, true); }
        onRejected: mainStack.pop()
    }
    Radar {
        id: miniRadar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20

        // Передаем только данные карты
        mapData: engine.currentLevelMap

        // Управление видимостью из настроек (как мы обсуждали)
        visible: window.showRadar && !isEndOfPack && opacity > 0
    }
}
