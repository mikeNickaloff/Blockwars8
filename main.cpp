#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>
#include <QFile>
#include <QRandomGenerator>
#include <QByteArray>
#include "appview.h"
#include "pool.h"
#include "irc.h"
#include "powerupeditordialog.h"
#include <QApplication>
int main(int argc, char *argv[])
{
    qputenv("QML_DISABLE_DISK_CACHE", "true");

   // XBacktrace::enableBacktraceLogOnUnhandledException();

    //QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    Q_UNUSED(app);
    qmlRegisterType<Pool>("com.blockwars", 1, 0, "Pool");
    qmlRegisterType<IRC>("com.blockwars",1,0,"IRC");
    qmlRegisterType<PowerupEditorDialog>("com.blockwars", 1, 0, "PowerupEditorDialog");

    AppView view;
    view.start();

    return app.exec();
}
