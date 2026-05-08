.pragma library

var themes = {
    "classicos": {
        name: "JasonWalt Bab@'s Classicos",
        path: "Assets/JasonWalt Bab@'s Classicos/",
        isSmooth: "true",
        textColor: "#000000",
        accentColor: "#555555"
    },
    "terminal": {
        name: "Interesting Terminal",
        path: "Assets/Interesting Terminal/",
        isSmooth: "false",
        textColor: "#32CD32", // Тот самый сочный зелёный
        accentColor: "#00FF00"
    },
    "dos": {
        name: "Old DOS",
        path: "Assets/Old DOS/",
        isSmooth: "false",
        textColor: "#FFFFFF",
        accentColor: "#AAAAAA"
    },
    "au_console": {
        name: "AU Console",
        path: "Assets/AU Console/",
        isSmooth: "false",
        textColor: "#FFFF00",
        accentColor: "#FFA500"
    },
    "tron": {
        "name": "T.H.R.O.N.E",
        "background": "#0D0208",
        "accent": "#00FFFF",
        "goal_box": "#32CD32",
        "path": "Assets/T.H.R.O.N.E/",
        "isSmooth": "true",
        "textColor": "#00FFFF", // Циан
        "accentColor": "#008B8B"
    },
    /*"Ubuntu Xenzia": {
        "name": "Ubuntu Xenzia",
        "background": "#333333",
        "isSmooth": "true",
        "textColor": "#",
        "accentColor": "",
        "path": "Assets/Ubuntu Xenzia/"
    }*/
    //Fucking Canonical, I hate Britishs

    /*"UBports Mania": {
        "name": "UBports Mania",
        "background": "#111111",
        "accent": "#e964763",
        "isSmooth": "true",
        "textColor": "#",
        "path": "Assets/UBports Mania/"
    }*/

};

// Используем текущий ключ темы
var currentThemeKey = "classicos";

function getThemeKeys() {
    return Object.keys(themes);
}

function getUrl(resourceName) {
    var theme = themes[currentThemeKey];
    var res = resourceName.indexOf(".") !== -1 ? resourceName : resourceName + ".svg";
    return theme.path + res;
}

function getTextColor() {
    return themes[currentThemeKey].textColor || "#FFFFFF";
}

function getThemeName() {
    return themes[currentThemeKey].name;
}

function setTheme(key) {
    if (themes[key]) {
        currentThemeKey = key;
        return true;
    }
    return false;
}

function isSmooth() {
    return themes[currentThemeKey].isSmooth === "true";
}
