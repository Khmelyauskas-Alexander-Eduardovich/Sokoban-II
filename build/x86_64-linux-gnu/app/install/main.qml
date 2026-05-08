import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.LocalStorage 2.0
import "ThemeManager.js" as Theme
import "LevelData.js" as LevelData
import "GameLogic.js" as Logic

ApplicationWindow {
    id: window
    visible: true
    width: 800; height: 600
    title: qsTr("Sokoban II")

    // --- Глобальные настройки ---
    property string activeTheme: "classicos"
    property bool showMenuAnimation: true
    property bool showLog: true
    property bool fullscreenMode: false
    property bool showRadar: true
    visibility: fullscreenMode ? Window.FullScreen : Window.Windowed

    // --- Игровой прогресс ---
    property string currentPackName: "levels_JasonWalt_Bab@s_set.js"
    property int currentLevelIdx: 0

    color: {
        if (activeTheme === "tron") return "#0D0208";
        if (activeTheme === "terminal") return "#0D0208";
        if (activeTheme === "green_pitch") return "#000000";
        if (activeTheme === "dos") return "#21f0ff";
        if (activeTheme === "au_console") return "#0000AA";
        if (activeTheme === "UBports Mania") return "#762572"
        return "#F2F2F7";
    }

    // Авто-сохранение настроек при их изменении
    onActiveThemeChanged: dbManager.saveAllSettings()
    onShowMenuAnimationChanged: dbManager.saveAllSettings()
    onShowLogChanged: dbManager.saveAllSettings()
    onFullscreenModeChanged: dbManager.saveAllSettings()
    onShowRadarChanged: dbManager.saveAllSettings()

    // --- МЕНЕДЖЕР БАЗЫ ДАННЫХ ---
    QtObject {
        id: dbManager
        property var db: null

        function initDb() {
            if (db) return;
            try {
                db = LocalStorage.openDatabaseSync("SokobanII", "1.0", "SaveData", 1000000);
                db.transaction(function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(key TEXT UNIQUE, value TEXT)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS pack_progress(pack_id TEXT UNIQUE, level_idx INTEGER)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS snapshots(pack_id TEXT, level_idx INTEGER, map_json TEXT, PRIMARY KEY(pack_id, level_idx))');
                });
            } catch (err) {
                console.log("Error opening database: " + err);
            }
        }

        function saveAllSettings() {
            initDb();
            if (!db) return;
            db.transaction(function(tx) {
                tx.executeSql("INSERT OR REPLACE INTO settings VALUES(?, ?)", ["theme", window.activeTheme]);
                tx.executeSql("INSERT OR REPLACE INTO settings VALUES(?, ?)", ["showMenuAnimation", window.showMenuAnimation ? "1" : "0"]);
                tx.executeSql("INSERT OR REPLACE INTO settings VALUES(?, ?)", ["showLog", window.showLog ? "1" : "0"]);
                tx.executeSql("INSERT OR REPLACE INTO settings VALUES(?, ?)", ["fullscreenMode", window.fullscreenMode ? "1" : "0"]);
                tx.executeSql("INSERT OR REPLACE INTO settings VALUES(?, ?)", ["showRadar", window.showRadar ? "1" : "0"]);
                tx.executeSql("INSERT OR REPLACE INTO settings VALUES(?, ?)", ["lastPack", window.currentPackName]);
            });
            Theme.setTheme(window.activeTheme);
        }

        function saveProgress(packName, idx) {
            initDb();
            if (!db) return;
            db.transaction(function(tx) {
                tx.executeSql("INSERT OR REPLACE INTO pack_progress VALUES(?, ?)", [packName, idx]);
            });
        }

        function saveSnapshot() {
            if (!db || !engine.currentLevelMap || engine.currentLevelMap.length === 0) return;
            db.transaction(function(tx) {
                var mapData = JSON.stringify(engine.currentLevelMap);
                tx.executeSql("INSERT OR REPLACE INTO snapshots VALUES(?, ?, ?)",
                    [window.currentPackName, window.currentLevelIdx, mapData]);
            });
        }

        function clearSnapshot(pack, idx) {
            initDb();
            if (!db) return;
            db.transaction(function(tx) {
                tx.executeSql("DELETE FROM snapshots WHERE pack_id=? AND level_idx=?", [pack, idx]);
            });
        }

        function loadPackAndLevel(packFile) {
                    if (LevelData.loadPack(packFile)) {
                        window.currentPackName = packFile;
                        var targetIdx = 0;
                        db.transaction(function(tx) {
                            var rs = tx.executeSql("SELECT level_idx FROM pack_progress WHERE pack_id=?", [packFile]);
                            if (rs.rows.length > 0) targetIdx = rs.rows.item(0).level_idx;
                        });
                        window.currentLevelIdx = targetIdx;
                        engine.loadLevel(targetIdx, false);
                    }
                }

        function boot() {
            initDb();
            if (!db) return;
            var lastPack = "levels_JasonWalt_Bab@s_set.js";

            db.transaction(function(tx) {
                var rs = tx.executeSql("SELECT key, value FROM settings");
                for (var i = 0; i < rs.rows.length; i++) {
                    var item = rs.rows.item(i);
                    if (item.key === "theme") window.activeTheme = item.value;
                    if (item.key === "showMenuAnimation") window.showMenuAnimation = (item.value === "1");
                    if (item.key === "showLog") window.showLog = (item.value === "1");
                    if (item.key === "fullscreenMode") window.fullscreenMode = (item.value === "1");
                    if (item.key === "lastPack") lastPack = item.value;
                    if (item.key === "showRadar") window.showRadar = (item.value === "1")
                }
            });

            window.currentPackName = lastPack;
            Theme.setTheme(window.activeTheme);

            // Загружаем пак и уровень
            if (LevelData.loadPack(lastPack)) {
                var targetIdx = 0;
                db.transaction(function(tx) {
                    var rs = tx.executeSql("SELECT level_idx FROM pack_progress WHERE pack_id=?", [lastPack]);
                    if (rs.rows.length > 0) targetIdx = rs.rows.item(0).level_idx;
                });
                window.currentLevelIdx = targetIdx;
                engine.loadLevel(targetIdx, false); // false = пытаемся взять снапшот
            }
        }
    }

    // --- ДВИЖОК ИГРЫ ---
    QtObject {
        id: engine
        property var currentLevelMap: []
        property var history: []
        property int px: 0; property int py: 0; property int mapW: 0;
        //property bool swipeMode: false

        function loadLevel(idx, isReset) {
            history = [];
            if (!LevelData.levels[idx]) idx = 0;
            window.currentLevelIdx = idx;

            var savedMap = null;

            // Если НЕ сброс, ищем сохраненку в базе через dbManager
            if (!isReset && dbManager.db) {
                dbManager.db.transaction(function(tx) {
                    var rs = tx.executeSql("SELECT map_json FROM snapshots WHERE pack_id=? AND level_idx=?",
                                            [window.currentPackName, idx]);
                    if (rs.rows.length > 0) {
                        try {
                            savedMap = JSON.parse(rs.rows.item(0).map_json);
                        } catch(e) { savedMap = null; }
                    }
                });
            }

            if (savedMap && savedMap.length > 0) {
                currentLevelMap = savedMap;
            } else {
                currentLevelMap = Logic.loadLevel(LevelData.levels[idx]);
                dbManager.clearSnapshot(window.currentPackName, idx);
            }

            setupMap();
            dbManager.saveProgress(window.currentPackName, idx);
            dbManager.saveSnapshot();
        }

        function setupMap() {
            if (!currentLevelMap || currentLevelMap.length === 0) return;
            var maxW = 0;
            for (var i = 0; i < currentLevelMap.length; i++) {
                if (currentLevelMap[i].length > maxW) maxW = currentLevelMap[i].length;
                var pPos = currentLevelMap[i].indexOf("@");
                if (pPos === -1) pPos = currentLevelMap[i].indexOf("+");
                if (pPos !== -1) { px = pPos; py = i; }
            }
            engine.mapW = maxW;
            refresh();
        }

        function refresh() {
            gameModel.clear();
            for (var y = 0; y < currentLevelMap.length; y++) {
                var row = currentLevelMap[y];
                for (var x = 0; x < mapW; x++) {
                    gameModel.append({"type": (x < row.length) ? row[x] : " "});
                }
            }
        }

        function step(dx, dy) {
            // Копируем через slice для скорости на мобилках
            var oldState = {
                "map": currentLevelMap.slice(),
                "px": px,
                "py": py
            };

            var res = Logic.tryMove(currentLevelMap, px, py, dx, dy);
            if (res && res.success) {
                history.push(oldState);
                currentLevelMap = res.newMap;
                px = res.newX; py = res.newY;
                refresh();
                dbManager.saveSnapshot();

                if (isWin()) {
                    dbManager.clearSnapshot(window.currentPackName, window.currentLevelIdx);
                    if (window.currentLevelIdx < LevelData.levels.length - 1) {
                        window.currentLevelIdx++;
                        loadLevel(window.currentLevelIdx, true); // След. уровень всегда чистый
                    } else {
                        if (mainStack.currentItem && mainStack.currentItem.finishDialog) {
                            mainStack.currentItem.finishDialog.open();
                        }
                    }
                }
            }
        }

        function isWin() {
            for (var y = 0; y < currentLevelMap.length; y++) {
                if (currentLevelMap[y].indexOf('.') !== -1 || currentLevelMap[y].indexOf('+') !== -1) return false;
            }
            return true;
        }

        function back() {
            if (history.length > 0) {
                var state = history.pop();
                currentLevelMap = state.map; px = state.px; py = state.py;
                refresh();
                dbManager.saveSnapshot();
            }
        }
    }

    ListModel { id: gameModel }
    StackView { id: mainStack; anchors.fill: parent; initialItem: "MainMenu.qml" }

    Component.onCompleted: dbManager.boot()
}
