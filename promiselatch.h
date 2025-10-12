#pragma once
#include <QObject>
#include <QHash>
#include <QJSValue>
#include <QJSEngine>
#include <QPointer>

class PromiseLatch : public QObject {
    Q_OBJECT
    Q_PROPERTY(int total READ total NOTIFY progress)
    Q_PROPERTY(int remaining READ remaining NOTIFY progress)
    Q_PROPERTY(bool done READ done NOTIFY doneChanged)
    Q_PROPERTY(bool failed READ failed NOTIFY failedChanged)

public:
    explicit PromiseLatch(QObject* parent=nullptr);

    // JS-style: supply a function(resolve, reject) that will call resolve()/reject() later.
    Q_INVOKABLE int require(QJSValue fn);

    // Named requirements (resolve from elsewhere later).
    Q_INVOKABLE int requireNamed(const QString& key);

    // Resolve/reject by numeric id (returned from require/requireNamed).
    Q_INVOKABLE void resolve(int id);
    Q_INVOKABLE void reject(int id);

    // Resolve/reject by key (set by requireNamed).
    Q_INVOKABLE void resolveNamed(const QString& key);
    Q_INVOKABLE void rejectNamed(const QString& key);
    Q_INVOKABLE void dispose();

    // Introspection
    int total() const { return m_total; }
    int remaining() const { return m_remaining; }
    bool done() const { return m_done; }
    bool failed() const { return m_failed; }

signals:
    void all();
    void failed(QString key);
    void progress(int remaining, int total);
    void doneChanged(bool done);
    void failedChanged(bool failedState);

private:
    enum class State { Pending, Resolved, Rejected };
    struct Entry {
        Entry() = default;
        Entry(const QString &keyValue, State initialState)
            : key(keyValue), state(initialState) {}

        QString key;        // optional
        State state = State::Pending;
    };

    int nextId();
    void tryFinish();
    void emitProgress();

    QJSEngine* jsEngineFor(const QJSValue& v) const;

    int m_nextId = 1;
    int m_total = 0;
    int m_remaining = 0;
    bool m_done = false;
    bool m_failed = false;

    QHash<int, Entry> m_entries;       // id -> entry
    QHash<QString,int> m_byKey;        // key -> id
};

// Convenience singleton to construct latches from QML (avoids QML component scaffolding)
class PromiseUtils : public QObject {
    Q_OBJECT
public:
    explicit PromiseUtils(QObject* parent=nullptr) : QObject(parent) {}
    Q_INVOKABLE PromiseLatch* create(QObject* parent=nullptr) { return new PromiseLatch(parent); }
};

class PromiseLatchCallbackProxy : public QObject {
    Q_OBJECT
public:
    PromiseLatchCallbackProxy(PromiseLatch* latch, int id, QObject* parent=nullptr);

    Q_INVOKABLE void resolve();
    Q_INVOKABLE void reject();

private:
    QPointer<PromiseLatch> m_latch;
    int m_id = 0;
};
