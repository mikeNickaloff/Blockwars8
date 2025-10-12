
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QVariant>
#include <QList>
#include <QObject>
#include <QJsonValue>
#include "datanode.h"


DataNode::DataNode(QObject *parent)
    : QObject(parent)
{
}

QString DataNode::getUuid()
{
    return getJsonData("uuid").toString();
}

void DataNode::setUuid( QString uuid)
{
    if (m_uuid != uuid) {
        m_uuid = uuid;
        setJsonData("uuid", uuid);
        emit uuidChanged();
    }
}

QJsonObject DataNode::getJsonDataObject()
{
    return m_jsonData;
}

void DataNode::setJsonDataObject( QJsonObject jsonData)
{
    if (m_jsonData != jsonData) {
        m_jsonData = jsonData;
        emit jsonDataChanged();
    }
}

QHash<QString, QVariant> DataNode::getCachedData()
{
    return m_cachedData;
}

void DataNode::setCachedData( QHash<QString, QVariant> cachedData)
{
    if (m_cachedData != cachedData) {
        m_cachedData = cachedData;
        emit cachedDataChanged();
    }
}

QHash<QString, DataNode*> DataNode::getChildNodes()
{
    return m_childNodes;
}

void DataNode::setChildNodes( QHash<QString, DataNode*> childNodes)
{
    if (m_childNodes != childNodes) {
        m_childNodes = childNodes;
        emit childNodesChanged();
    }
}

QString DataNode::getDataType()
{
    return m_dataType;
}

void DataNode::setDataType(QString dataType)
{
    if (m_dataType != dataType) {
        m_dataType = dataType;
        setJsonData("dataType", dataType);
        emit dataTypeChanged();
    }
}

void DataNode::setJsonData( QString key,  QVariant value)
{

    QJsonValue val = QJsonValue::fromVariant(value);
    m_jsonData.insert(key, val );
    cacheJsonData();
    if (key != "uuid") {
        emit this->jsonDataValueAssigned(this->getJsonData("uuid").toString(), key, value);
    }


}

void DataNode::cacheJsonData()
{
    m_cachedData.clear();
    for (auto it = m_jsonData.begin(); it != m_jsonData.end(); ++it) {
        m_cachedData.insert(it.key(), it.value().toVariant());
    }
    emit cachedDataChanged();
}

QVariant DataNode::getJsonData(QString key)
{
    if (m_cachedData.keys().contains(key)) {
        return m_cachedData.value(key);
    } else {
        setJsonData(key, QVariant::fromValue(QString("")));
        cacheJsonData();
        return m_cachedData.value(key);
    }
}
void DataNode::import(QJsonObject jsonDataString)
{
    QJsonObject jsonObject = jsonDataString;


    QVariantList childList;
    m_jsonData = jsonObject["jsonData"].toObject();

    m_uuid = jsonObject["uuid"].toString();
    childList = jsonObject["childNodes"].toArray().toVariantList();
    cacheJsonData();
    for (auto it = childList.begin(); it != childList.end(); ++it) {

        new_node = new DataNode(this);
        new_node->import(it->value<QJsonObject>());
        m_childNodes.insert(new_node->getUuid(), new_node);

    }

    m_dataType = jsonObject["dataType"].toString();


}

QJsonObject DataNode::exportData(bool encodeObject)
{

    QJsonObject jsonObject;
    jsonObject["jsonData"] = m_jsonData;
    jsonObject["uuid"] = getJsonData("uuid").toString();
    jsonObject["encoded"] = QJsonValue(encodeObject);
    QJsonArray childData;
    for (DataNode* childUuid : m_childNodes.values()) {
        QJsonValue str;
        str = QJsonValue(childUuid->exportData(encodeObject));
        childData.push_back(str);
    }
    jsonObject["childNodes"] = childData;
    jsonObject["dataType"] =  getJsonData("dataType").toString();
    if (encodeObject) {
        return encodeJson(jsonObject);
    } else {
        return jsonObject;
    }

}

DataNode* DataNode::findDataNode( QString uuid)
{
    if (m_uuid == uuid)
        return this;

    if (m_childNodes.keys().contains(uuid)) {
        return m_childNodes.value(uuid);

    }

    for (DataNode* childUuid : m_childNodes.values()) {
        DataNode* foundUuid = childUuid->findDataNode(uuid);
        if (foundUuid != nullptr)
            return foundUuid;
    }

    return nullptr;
}

QStringList DataNode::findAll( QString typeName)
{
    QStringList result;

    if (m_dataType == typeName)
        result.append(m_uuid);

    for (DataNode* childUuid : m_childNodes) {
        QStringList foundUuids = childUuid->findAll(typeName);
        result.append(foundUuids);
    }

    return result;
}

QJsonValue DataNode::encodeJson(QJsonValue val)
{
    QString rv;
    if (val.isArray()) { return QJsonValue(encodeJson(val.toArray())); }
    if (val.isObject()) { return QJsonValue(encodeJson(val.toObject())); }
    if (val.isString()) { return QJsonValue(encodeJson(val.toString())); }
    if (val.isBool()) { return QJsonValue(encodeJson(val.toBool())); }
    if (val.isDouble()) { return QJsonValue(encodeJson(val.toDouble())); }
    return QJsonValue(QString(""));
}

QJsonArray DataNode::encodeJson(QJsonArray val)
{
    QJsonArray rv;
    for (int i=0; i<val.count(); i++) {
        QJsonValue av = val.at(i);
        rv.append(encodeJson(av));
    }
    return rv;
}

QJsonObject DataNode::encodeJson(QJsonObject val)
{
    QJsonObject rv;
    QStringList keys;
    keys << val.keys();
    for (int i=0; i<keys.length(); i++) {
        QString key = keys.at(i);
        QJsonValue ov = encodeJson(val.value(key));
        rv.insert(key, ov);
    }
    return rv;
}

bool DataNode::encodeJson(bool val)
{
    return val;
}

double DataNode::encodeJson(double val)
{
    return val;
}

QString DataNode::encodeJson(QString val)
{
    QByteArray arr;
    arr = val.toLocal8Bit();
    QByteArray hex  = arr.toHex();
    QString rv = QString::fromLocal8Bit(hex);
    return rv;
}

// --------------------------------------------

QJsonValue DataNode::decodeJson(QJsonValue val)
{
    QString rv;
    if (val.isArray()) { return QJsonValue(decodeJson(val.toArray())); }
    if (val.isObject()) { return QJsonValue(decodeJson(val.toObject())); }
    if (val.isString()) { return QJsonValue(decodeJson(val.toString())); }
    if (val.isBool()) { return QJsonValue(decodeJson(val.toBool())); }
    if (val.isDouble()) { return QJsonValue(decodeJson(val.toDouble())); }
    return QJsonValue(QString(""));
}

QJsonArray DataNode::decodeJson(QJsonArray val)
{
    QJsonArray rv;
    for (int i=0; i<val.count(); i++) {
        QJsonValue av = val.at(i);
        rv.append(decodeJson(av));
    }
    return rv;
}

QJsonObject DataNode::decodeJson(QJsonObject val)
{
    QJsonObject rv;
    QStringList keys;
    keys << val.keys();
    for (int i=0; i<keys.length(); i++) {
        QString key = keys.at(i);
        QJsonValue ov = decodeJson(val.value(key));
        rv.insert(key, ov);
    }
    return rv;
}

bool DataNode::decodeJson(bool val)
{
    return val;
}

double DataNode::decodeJson(double val)
{
    return val;
}

QString DataNode::decodeJson(QString val)
{
    QByteArray arr;
    arr = val.toLocal8Bit();
    QByteArray hex  = QByteArray::fromHex(arr);
    QString rv = QString::fromLocal8Bit(hex);
    return rv;
}

void DataNode::addChildNode(DataNode *childNode)
{
    if (childNode && !m_childNodes.contains(childNode->getUuid())) {
        m_childNodes.insert(childNode->getUuid(), childNode);
        emit childNodesChanged();
    }
}

void DataNode::removeChildNode(DataNode *childNode)
{
    if (childNode && m_childNodes.contains(childNode->getUuid())) {
        m_childNodes.remove(childNode->getUuid());
        emit childNodesChanged();
    }
}

bool DataNode::containsChild( QString uuid)
{
    if (m_uuid == uuid)
        return true;

    for (DataNode *childNode : m_childNodes) {
        if (childNode->containsChild(uuid))
            return true;
    }

    return false;
}
