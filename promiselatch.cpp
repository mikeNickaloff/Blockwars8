#include "promiselatch.h"
#include <QtGlobal>
#include <QCoreApplication>

PromiseLatchCallbackProxy::PromiseLatchCallbackProxy(PromiseLatch* latch, int id, QObject* parent)
    : QObject(parent), m_latch(latch), m_id(id)
{
}

void PromiseLatchCallbackProxy::resolve()
{
    if (m_latch) {
        m_latch->resolve(m_id);
    }
    deleteLater();
}

void PromiseLatchCallbackProxy::reject()
{
    if (m_latch) {
        m_latch->reject(m_id);
    }
    deleteLater();
}

PromiseLatch::PromiseLatch(QObject* parent)
    : QObject(parent)
{
}

int PromiseLatch::nextId() {
    return m_nextId++;
}

QJSEngine* PromiseLatch::jsEngineFor(const QJSValue& v) const {
    // In Qt 5.15, QJSValue can return an engine via engine()
#if QT_VERSION >= QT_VERSION_CHECK(5, 12, 0)
    return v.engine();
#else
    return nullptr;
#endif
}

int PromiseLatch::require(QJSValue fn) {
    const int id = nextId();
    m_entries.insert(id, Entry{ /*key=*/QString(), State::Pending });
    ++m_total;
    ++m_remaining;
    emitProgress();

    // If it’s actually a callable, supply resolve/reject closures
    if (fn.isCallable()) {
        QJSEngine* eng = jsEngineFor(fn);
        if (eng) {
            auto proxy = new PromiseLatchCallbackProxy(this, id, this);
            QJSValue proxyValue = eng->newQObject(proxy);
            QJSValue resolveFn = proxyValue.property(QStringLiteral("resolve"));
            QJSValue rejectFn = proxyValue.property(QStringLiteral("reject"));
            if (resolveFn.isCallable() && rejectFn.isCallable()) {
                QJSValueList args; args << resolveFn << rejectFn;
                QJSValue ret = fn.call(args);
                Q_UNUSED(ret);
            }
        }
    }
    return id;
}

int PromiseLatch::requireNamed(const QString& key) {
    const int id = nextId();
    m_entries.insert(id, Entry{ key, State::Pending });
    if (!key.isEmpty())
        m_byKey.insert(key, id);
    ++m_total;
    ++m_remaining;
    emitProgress();
    return id;
}

void PromiseLatch::resolve(int id) {
    auto it = m_entries.find(id);
    if (it == m_entries.end()) return;
    if (it->state != State::Pending) return;

    it->state = State::Resolved;
    --m_remaining;
    emitProgress();
    tryFinish();
}

void PromiseLatch::reject(int id) {
    auto it = m_entries.find(id);
    if (it == m_entries.end()) return;
    if (it->state != State::Pending) return;

    it->state = State::Rejected;
    --m_remaining;
    if (!m_failed) {
        m_failed = true;
        emit failedChanged(m_failed);
        emit failed(it->key);
    }
    emitProgress();
    tryFinish();
}

void PromiseLatch::resolveNamed(const QString& key) {
    auto it = m_byKey.find(key);
    if (it != m_byKey.end()) resolve(*it);
}

void PromiseLatch::rejectNamed(const QString& key) {
    auto it = m_byKey.find(key);
    if (it != m_byKey.end()) reject(*it);
}

void PromiseLatch::tryFinish() {
    if (m_done) return;
    // Done when all requirements are non-pending
    bool anyPending = false;
    for (const auto& e : m_entries) {
        if (e.state == State::Pending) { anyPending = true; break; }
    }
    if (!anyPending) {
        m_done = true;
        emit doneChanged(true);
        if (!m_failed) {
            emit all();
        }
    }
}

void PromiseLatch::emitProgress() {
    emit progress(m_remaining, m_total);
}

void PromiseLatch::dispose()
{
    deleteLater();
}
