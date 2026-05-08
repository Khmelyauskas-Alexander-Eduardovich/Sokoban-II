import QtQuick 2.12

Item {
    id: root
    width: 200
    height: 200

    property double threshold: 30
    property bool canMove: true // Флаг: можно ли делать шаг прямо сейчас

    signal move(int dx, int dy)
    signal doubleClick()

    // Таймер, который ограничивает скорость ходьбы
    Timer {
        id: moveTimer
        interval: 200 // Скорость (в мс). Поставь 300, если хочешь ещё медленнее.
        onTriggered: canMove = true
    }

    // Внешний круг (обводка)
    Rectangle {
        id: outerCircle
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: "white"
        border.width: 4
        opacity: 0.5
    }

    // Внутренний круг (заливка)
    Rectangle {
        id: innerCircle
        width: 80; height: 80
        radius: 40
        color: "white"
        x: (parent.width / 2) - radius
        y: (parent.height / 2) - radius

        Behavior on x { NumberAnimation { duration: 50; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 50; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        onDoubleClicked: root.doubleClick()

        onPositionChanged: {
                    var centerX = root.width / 2
                    var centerY = root.height / 2

                    var dx = mouse.x - centerX
                    var dy = mouse.y - centerY

                    // МАГИЯ «КРЕСТА»: Принудительно выбираем только одну доминирующую ось
                    if (Math.abs(dx) > Math.abs(dy)) {
                        dy = 0; // Игнорируем вертикаль, если палец больше смещён по горизонтали
                    } else {
                        dx = 0; // Игнорируем горизонталь
                    }

                    var dist = Math.abs(dx + dy) // Так как одна ось всегда 0, это упрощает расчет
                    var maxDist = root.width / 2 - innerCircle.width / 2

                    // Ограничиваем дистанцию по осям
                    if (dist > maxDist) {
                        if (dx !== 0) dx = (dx > 0 ? maxDist : -maxDist)
                        if (dy !== 0) dy = (dy > 0 ? maxDist : -maxDist)
                    }

                    // Плавное обновление позиции кружка (теперь он ходит только крестом!)
                    innerCircle.x = centerX + dx - innerCircle.width / 2
                    innerCircle.y = centerY + dy - innerCircle.height / 2

                    // Логика шага персонажа (кулдаун из прошлого сообщения)
                    if (canMove && (Math.abs(dx) > threshold || Math.abs(dy) > threshold)) {
                        canMove = false;
                        moveTimer.start();

                        if (dx !== 0) {
                            root.move(dx > 0 ? 1 : -1, 0)
                        } else if (dy !== 0) {
                            root.move(0, dy > 0 ? 1 : -1)
                        }
                    }
                }

        onReleased: {
            innerCircle.x = (root.width / 2) - innerCircle.radius
            innerCircle.y = (root.height / 2) - innerCircle.radius
        }
    }
}
