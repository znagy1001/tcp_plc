#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "UDI.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    UDI* udi = new UDI();
    udi->initialize();

    QObject::connect(&app, SIGNAL(aboutToQuit()), udi, SLOT(onQuit()));

    // for enum
    qmlRegisterType<UDI>("UDI", 1, 1, "UDI");

    engine.rootContext()->setContextProperty("udi", udi);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) return -1;

    return app.exec();
}
