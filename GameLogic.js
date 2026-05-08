//GameLogic.js
.import "LevelParser.js" as Parser
.import "LevelData.js" as Data

var currentMap = [];

function loadLevel(data) {
    if (!data) return [];

        // Если это массив (как в твоем файле), отдаем его сразу парсеру
        // Если это объект (где есть .map или .layout), парсер сам разберется
        return Parser.parse(data);
}

function tryMove(lvlMap, x, y, dx, dy) {
    // lvlMap вместо map
    var newMap = lvlMap.slice();
    var nX = x + dx;
    var nY = y + dy;

    if (nY < 0 || nY >= newMap.length || nX < 0 || nX >= newMap[nY].length) return { "success": false };

    var target = newMap[nY][nX];
    if (target === "#" || target === "X") return { "success": false };

    // Логика ящика
    if (target === "$" || target === "*") {
        var bX = nX + dx;
        var bY = nY + dy;
        if (bY < 0 || bY >= newMap.length || bX < 0 || bX >= newMap[bY].length) return { "success": false };

        var bTarget = newMap[bY][bX];
        if (bTarget === " " || bTarget === ".") {
            var rowTo = newMap[bY].split("");
            rowTo[bX] = (bTarget === ".") ? "*" : "$";
            newMap[bY] = rowTo.join("");

            var rowFrom = newMap[nY].split("");
            rowFrom[nX] = (target === "*") ? "." : " ";
            newMap[nY] = rowFrom.join("");
        } else return { "success": false };
    }

    // Логика игрока (обновляем target, так как он мог измениться ящиком)
    var finalTarget = newMap[nY][nX];
    var pOldRow = newMap[y].split("");
    pOldRow[x] = (lvlMap[y][x] === "+" || lvlMap[y][x] === ".") ? "." : " ";
    newMap[y] = pOldRow.join("");

    var pNewRow = newMap[nY].split("");
    pNewRow[nX] = (finalTarget === "." || finalTarget === "*") ? "+" : "@";
    // Заметь: если там был ящик, мы его уже подвинули, поэтому тут просто ставим игрока
    newMap[nY] = pNewRow.join("");

    return { "success": true, "newX": nX, "newY": nY, "newMap": newMap };
}
