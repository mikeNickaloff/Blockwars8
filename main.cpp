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
#include "promiselatch.h"

#include <QApplication>

static QObject* promise_utils_singletontype(QQmlEngine*, QJSEngine*) {
    return new PromiseUtils();
}

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
    qmlRegisterType<PromiseLatch>("Promises", 1, 0, "Promise");
    qmlRegisterSingletonType<PromiseUtils>("Promises", 1, 0, "PromiseUtils", promise_utils_singletontype);

    AppView view;
    view.start();

    return app.exec();
}
