#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QObject>
#include <QHash>
#include <QString>
#include <QQmlEngine>
#include <QJsonArray>
#include <QJsonObject>

class IRCSocket;
class DataNode;
class Database : public QObject
{
    Q_OBJECT
public:
    explicit Database(QObject *parent = nullptr);
  Q_INVOKABLE QString generateUuid();
  Q_INVOKABLE void connectToIRC();
  Q_INVOKABLE QVariant getDataNodeJsonValue(QString uuid, QString jsonKey);
  Q_INVOKABLE QString createDataNode(QString node_type = "", QString uuid = "");
  Q_INVOKABLE void setDataNodeJsonValue(QString uuid, QString jsonKey, QVariant jsonValue);
  Q_INVOKABLE DataNode* getDataNode(QString uuid);
  Q_INVOKABLE void importDataNode(QJsonObject obj);
  Q_INVOKABLE QJsonArray listDataNodes(QJsonObject matchingProperties, bool invert = false);
  Q_INVOKABLE void startMultiplayer(QJsonArray abilities);


  QHash<QString, DataNode*> m_dataNodes;
  DataNode* new_node;
  IRCSocket* m_irc;


  Q_INVOKABLE QString ircMyNickname();
  Q_INVOKABLE QString ircOpponentNickname();
  Q_INVOKABLE DataNode* createBlockNode(QJsonObject blockData);
signals:
void blockNodeCreated(QJsonObject blockData);
void dataNodeJsonDataUpdate(QString uuid, QString key, QVariant value);
public slots:
void handleDataNodeJsonDataChange(QString uuid, QString key, QVariant value);
};

#endif // DATABASE_H
