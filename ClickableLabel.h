#include <QEvent>
#include <QLabel>

class ClickableLabel : public QObject
{
    Q_OBJECT
public:
    ClickableLabel(QObject *parent, std::function<void()> onClick)
        : QObject(parent), m_onClick(onClick)
    {
    }

protected:
    bool eventFilter(QObject *obj, QEvent *event) override
    {
        if (event->type() == QEvent::MouseButtonPress) {
            m_onClick();
            return true;
        } else {
            return QObject::eventFilter(obj, event);
        }
    }

private:
    std::function<void()> m_onClick;
};
