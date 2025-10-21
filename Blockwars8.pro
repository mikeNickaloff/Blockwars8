TEMPLATE = app

QT += qml quick network  quickcontrols2   websockets widgets gui
CONFIG += c++11

QT += quick qml

SOURCES += main.cpp \
  database.cpp \
  datanode.cpp \
  ircsocket.cpp \
  pool.cpp \
  powerupeditordialog.cpp

SOURCES += $$PWD/appview.cpp

RESOURCES += \
    $$PWD/Blockwars8.qrc

INCLUDEPATH += $$PWD

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += $$PWD

HEADERS += \
    $$PWD/appview.h \
    ClickableLabel.h \
    database.h \
    datanode.h \
    irc.h \
    ircsocket.h \
    pool.h \
    powerupeditordialog.h

ROOT_DIR = $$PWD

# Default rules for deployment.
include(deployment.pri)
include(quickflux/quickflux.pri)

DISTFILES += \
    WHEEL.md \
    qpm.json \
    qpm.pri

