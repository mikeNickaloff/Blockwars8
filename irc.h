#ifndef IRC_H
#define IRC_H

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTcpSocket>

class IRC : public QObject
{
    Q_OBJECT

public:
    IRC() : socket(new QTcpSocket(this)) {
        connect(socket, &QTcpSocket::connected, this, &IRC::onConnected);
        connect(socket, &QTcpSocket::readyRead, this, &IRC::onReadyRead);
    }

    Q_INVOKABLE void connectToServer(const QString& server, int port) {
        socket->connectToHost(server, port);
    }

    Q_INVOKABLE void sendMessage(const QString& message) {
        socket->write(message.toUtf8() + "\r\n");
    }
    QString game_channel;

private slots:
    void onConnected() {
        qDebug() << "Connected to server";
        socket->write("NICK YourNickname\r\n");
        socket->write("USER username 0 0 :realname\r\n");
    }

    void onReadyRead() {
        qDebug() << "Data received:" << socket->readAll();
        QByteArray data = socket->readAll();
           if (data.startsWith("PING")) {
               QByteArray response = "PONG" + data.mid(4);
               socket->write(response);
           }
    }
    void sendToGame(QString message) {

    }

private:
    QTcpSocket* socket;
};




#endif // IRC_H
