import QtQuick 2.12
import QtGraphicalEffects 1.12

Item {
    id: radarRoot
    width: 140; height: 140

    property var mapData: engine.currentLevelMap
    property real cellSize: 12

    // 1. Считаем реальную ширину (макс. длина строки)
    readonly property int realWidth: {
        var maxW = 0;
        if (mapData) {
            for (var i = 0; i < mapData.length; i++) {
                if (mapData[i].length > maxW) maxW = mapData[i].length;
            }
        }
        return maxW > 0 ? maxW : 1;
    }

    // 2. Создаем ровный плоский массив и ЗАОДНО ищем игрока
    // Это гарантирует, что координаты игрока совпадут с сеткой радара
    property int internalPlayerX: 0
    property int internalPlayerY: 0
    property bool isPlayerOnGoal: false

    property var flatData: {
            var res = [];
            var targetW = realWidth;
            var pX = 0;
            var pY = 0;
            var onGoal = false;

            if (mapData && mapData.length > 0) {
                for (var i = 0; i < mapData.length; i++) {
                    var row = mapData[i];
                    if (row) {
                        for (var j = 0; j < targetW; j++) {
                            // Переименовали char -> symbol
                            var symbol = (j < row.length) ? row[j] : " ";
                            res.push(symbol);

                            // Ищем нашего Циана
                            if (symbol === "@" || symbol === "+") {
                                pX = j;
                                pY = i;
                                onGoal = (symbol === "+");
                            }
                        }
                    }
                }
            }
            internalPlayerX = pX;
            internalPlayerY = pY;
            isPlayerOnGoal = onGoal;
            return res;
        }

    Rectangle {
        id: radarMask
        anchors.fill: parent
        radius: width / 2; visible: false
    }

    Item {
        id: maskContainer
        anchors.fill: parent
        layer.enabled: true
        layer.effect: OpacityMask { maskSource: radarMask }

        Rectangle { anchors.fill: parent; color: "#1a1a1a" }

        Item {
            id: mapCanvas
            width: realWidth * cellSize
            height: (flatData.length / realWidth) * cellSize

            // Центрируем карту по внутренним координатам
            x: (radarRoot.width / 2) - (internalPlayerX * cellSize) - (cellSize / 2)
            y: (radarRoot.height / 2) - (internalPlayerY * cellSize) - (cellSize / 2)

            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            Repeater {
                model: flatData
                delegate: Item {
                    x: (index % realWidth) * cellSize
                    y: Math.floor(index / realWidth) * cellSize
                    width: cellSize; height: cellSize

                    Rectangle {
                        anchors.fill: parent
                        color: modelData !== " " ? "#444" : "transparent"
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "#222"
                        visible: modelData === "#"
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.6; height: width; radius: width / 2
                        color: "#FF3B30"
                        visible: modelData === "." || modelData === "*" || modelData === "+"
                    }

                    Rectangle {
                        anchors.fill: parent; anchors.margins: 1
                        color: modelData === "*" ? "#34C759" : "#FFD700"
                        visible: modelData === "$" || modelData === "*"
                    }

                    // Тот самый Циан (рисуем прямо в сетке)
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.9; height: width; radius: width / 2
                        color: modelData === "+" ? "#A6FF00" : "#00FFFF"
                        border.color: "white"; border.width: 1
                        visible: modelData === "@" || modelData === "+"
                        z: 10
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"; border.color: "white"; border.width: 2; radius: width / 2
    }
}
