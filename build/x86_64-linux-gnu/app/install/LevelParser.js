// LevelParser.js
.pragma library

function parse(levelData) {
    if (!levelData) return [];

    // Если прилетела функция (тот самый конфликт имен) — это плохо.
    if (typeof levelData === "function") {
        console.log("Parser ALARM: Received a function instead of data!");
        return [];
    }

    // Если это массив массивов (как у Yoshio)
    if (Array.isArray(levelData)) {
        // Проверяем первый элемент. Если это строка — значит это и есть карта.
        if (typeof levelData[0] === "string") return levelData;
        // Если это массив объектов, ищем поле layout или map
        if (typeof levelData[0] === "object") {
             return levelData[0].layout || levelData[0].map || [];
        }
    }

    return [];
}
