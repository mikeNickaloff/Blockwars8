#ifndef DATANODE_H
#define DATANODE_H

#include <QObject>
#include <QJsonObject>
#include <QHash>
#include <QString>
#include <QStringList>
#include <QVariant>



class DataNode : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString uuid READ getUuid WRITE setUuid NOTIFY uuidChanged)
    Q_PROPERTY(QJsonObject jsonData READ getJsonDataObject WRITE setJsonDataObject NOTIFY jsonDataChanged)
    Q_PROPERTY(QHash<QString, QVariant> cachedData READ getCachedData WRITE setCachedData NOTIFY cachedDataChanged)
    Q_PROPERTY(QHash<QString, DataNode*> childNodes READ getChildNodes WRITE setChildNodes NOTIFY childNodesChanged)
    Q_PROPERTY(QString dataType READ getDataType WRITE setDataType NOTIFY dataTypeChanged)

public:
     DataNode(QObject *parent = nullptr);

    QString defaultTemplate;
    QString createTemplateString(QString templateStr) {
          QString renderedTemplate = templateStr;

          QJsonObject jsonDataObj = this->m_jsonData;
          QJsonObject::iterator it;
          for (it = jsonDataObj.begin(); it != jsonDataObj.end(); ++it) {
              QString key = it.key();
              QString value = it.value().toString();

              QString placeholder = "%" + key + "%";
              QString placeholderKey = "%" + key + ":key%";

              renderedTemplate.replace(placeholder, value);
              renderedTemplate.replace(placeholderKey, key);
          }

          return renderedTemplate;
      }
    QString createQMLComponent(QString templateStr = "") {
         QString templateToUse = templateStr.isEmpty() ? defaultTemplate : templateStr;
         QString renderedTemplate = createTemplateString(templateToUse);

         // Create the QML component string using the rendered template
         QString qmlComponent = "import QtQuick 2.15\n"
                                "Item {\n"
                                + renderedTemplate +
                                "}\n";

         return qmlComponent;
     }
   Q_INVOKABLE QString getUuid() ;
    void setUuid( QString uuid);

    QJsonObject getJsonDataObject() ;
    void setJsonDataObject( QJsonObject jsonData);

    QHash<QString, QVariant> getCachedData() ;
    void setCachedData(QHash<QString, QVariant> cachedData);

    QHash<QString, DataNode*> getChildNodes() ;
    void setChildNodes( QHash<QString, DataNode*> childNodes);

    QString getDataType() ;
    void setDataType( QString dataType);

    Q_INVOKABLE void setJsonData( QString key,  QVariant value);
    Q_INVOKABLE void cacheJsonData();
    Q_INVOKABLE QVariant getJsonData( QString key);
    Q_INVOKABLE void import(QJsonObject jsonDataString);
    Q_INVOKABLE QJsonObject exportData(bool encodeObject = false);
    Q_INVOKABLE DataNode* findDataNode( QString uuid);
    Q_INVOKABLE QStringList findAll( QString typeName);
    QJsonValue encodeJson(QJsonValue val);
    QJsonArray encodeJson(QJsonArray val);
    QJsonObject encodeJson(QJsonObject val);
    bool encodeJson(bool val);
    double encodeJson(double val);
    QString encodeJson(QString val);

    //-----------
    QJsonValue decodeJson(QJsonValue val);
    QJsonArray decodeJson(QJsonArray val);
    QJsonObject decodeJson(QJsonObject val);
    bool decodeJson(bool val);
    double decodeJson(double val);
    QString decodeJson(QString val);

    DataNode* new_node;
    QString m_uuid;
    QJsonObject m_jsonData;
    QHash<QString, QVariant> m_cachedData;
    QHash<QString, DataNode*> m_childNodes;
    QString m_dataType;

    bool containsChild( QString uuid);
Q_INVOKABLE void addChildNode(DataNode *childNode);
signals:
    void uuidChanged();
    void jsonDataChanged();
    void cachedDataChanged();
    void childNodesChanged();
    void dataTypeChanged();
    void jsonDataValueAssigned(QString uuid, QString key, QVariant value);

protected:

      void removeChildNode(DataNode *childNode);
private:

};
#endif
