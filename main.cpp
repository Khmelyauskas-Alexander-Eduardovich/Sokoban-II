#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QLocale>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    // Оставляем твой указатель, раз тебе так удобнее работать с памятью
    QGuiApplication *app = new QGuiApplication(argc, (char**)argv);

    // Твое адаптивное имя под SQL-базу
    app->setApplicationName("sokoban2.jwb-tutantxamon");

    // Фикс для создания путей базы данных (чтобы LocalStorage не ругался)
    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/QML/OfflineStorage/Databases";
    QDir dir;
    if (!dir.exists(dataPath)) {
        dir.mkpath(dataPath);
    }

    QTranslator translator;
    if (translator.load(QLocale(), "base", "_", ":/translations")) {
        app->installTranslator(&translator);
        qDebug() << "Translation loaded for locale:" << QLocale().name();
    } else {
        qDebug() << "Failed to load translation!";
    }
    QQmlApplicationEngine engine;

    // Возвращаем qrc:/, так как ты используешь RESOURCES в .pro
    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app->exec();
}
