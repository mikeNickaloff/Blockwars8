#include "database.h"
#include "datanode.h"
#include <QQmlEngine>
#include <QQmlContext>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QRandomGenerator>
#include <QQmlComponent>
#include <QQuickItem>
#include <QtDebug>
#include <QDateTime>
#include <QHash>
#include <QDesktopServices>
#include <QUrl>
#include <QtDebug>
#include "ircsocket.h"
Database::Database(QObject *parent)
    : QObject{parent}
{

}
QString Database::generateUuid()
{
    QString characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    const int length = 10;

    QString uuid;
    for (int i = 0; i < length; ++i) {
        int index = QRandomGenerator::global()->bounded(characters.length());
        uuid.append(characters.at(index));
    }

    return uuid;
}

void Database::connectToIRC()
{
    m_irc = new IRCSocket();
    m_irc->connectToServer("core.datafault.net", 6667, generateUuid());

}

QVariant Database::getDataNodeJsonValue(QString uuid, QString jsonKey)
{
    if (m_dataNodes.contains(uuid)) {
        DataNode* node = m_dataNodes.value(uuid);
        return node->getJsonData(jsonKey);
    } else {
        return QVariant::fromValue(QString(""));
    }
}

QString Database::createDataNode(QString node_type, QString uuid)
{
    QString _uuid;
    if (uuid == "") {
        _uuid = generateUuid();
    } else {
        _uuid = uuid;
    }
    qDebug() << "creating data node " << node_type << _uuid;
    if (m_dataNodes.keys().contains(_uuid)) {
        qDebug() << "uuid" << _uuid << "exists, can not call createDataNode of type" << node_type;
        _uuid = generateUuid();
        new_node = new DataNode(this);
        m_dataNodes[_uuid] = new_node;
        new_node->setJsonData("uuid", _uuid);
        return _uuid;

    } else {
        new_node = new DataNode(this);
        m_dataNodes.insert(_uuid, new_node);
        new_node->setJsonData("uuid", _uuid);
        return _uuid;
    }
}

void Database::setDataNodeJsonValue(QString uuid, QString jsonKey, QVariant jsonValue)
{
    if (m_dataNodes.contains(uuid)) {
        DataNode* node = m_dataNodes.value(uuid);
        node->setJsonData(jsonKey, jsonValue);
    }

}

DataNode *Database::getDataNode(QString uuid)
{
    if (m_dataNodes.contains(uuid)) {
        return m_dataNodes.value(uuid);
    } else {
        qDebug() << "Invalid uuid" << uuid << "passed to getDataNode";
        return nullptr;
    }
}

void Database::importDataNode(QJsonObject obj)
{
    QString uuid = obj.value("uuid").toString();
    DataNode* node;
    if (m_dataNodes.contains(uuid)) {
        node = getDataNode(uuid);
    } else {
        node = new DataNode(this);
        m_dataNodes[uuid] = new_node;
        node->setJsonData("uuid", uuid);

    }
    node->import(obj);
}

QJsonArray Database::listDataNodes(QJsonObject matchingProperties,  bool invert)
{
    QJsonArray rv;
    QHash<QString, DataNode*>::const_iterator i = m_dataNodes.constBegin();
    while (i != m_dataNodes.constEnd()) {
        i++;
        DataNode* node = i.value();
        QStringList keys;
        keys << matchingProperties.keys();
        bool triggered_match = false;

        for (int u=0; u<keys.length(); u++) {
            if (node->getJsonData(matchingProperties.value(keys.at(u)).toString()).toJsonValue() == QJsonValue(matchingProperties.value(keys.at(u))))  {

                triggered_match = true;
                continue;

            } else {

                triggered_match = false;
                break;

            }
        }


        if (triggered_match) {
            if (!invert) {
                rv.append(node->getJsonData("uuid").toString());
            }
        } else {
            if (invert) {
                rv.append(node->getJsonData("uuid").toString());
            }
        }


        i++;
    }
    return rv;
}

void Database::startMultiplayer(QJsonArray abilities)
{
    m_irc->joinChannel(QString("#remote_random_%1").arg(m_irc->my_nickname));
}

QString Database::ircMyNickname()
{
    return m_irc->my_nickname;
}

QString Database::ircOpponentNickname()
{
    return m_irc->opponent_nickname;
}

DataNode* Database::createBlockNode(QJsonObject blockData)
{
    qDebug() << "database: creating block node" << blockData;
    QString block_id = this->createDataNode("block", "");
    qDebug() << "database: block id " << block_id;
    DataNode* node = this->getDataNode(block_id);
    node->setJsonDataObject(blockData);
    node->setJsonData("uuid", block_id);
    node->setJsonData("dataType", "block");
    this->connect(node, SIGNAL(jsonDataValueAssigned(QString, QString, QVariant)), this, SLOT(handleDataNodeJsonDataChange(QString, QString, QVariant)));
    qDebug() << "databaase:" << node->exportData().value("jsonData").toObject();
    emit this->blockNodeCreated(node->exportData().value("jsonData").toObject());
    return node;
}

void Database::handleDataNodeJsonDataChange(QString uuid, QString key, QVariant value)
{
    emit this->dataNodeJsonDataUpdate( uuid, key, value);
}
