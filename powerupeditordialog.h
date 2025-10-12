#ifndef POWERUPEDITORDIALOG_H
#define POWERUPEDITORDIALOG_H

#include <QObject>
#include <QDialogButtonBox>
#include <QFormLayout>
#include <QLabel>
#include <QPushButton>
#include <QHash>
#include <QWidget>
#include <QComboBox>
#include <QSpinBox>
#include <QJsonObject>
#include <QJsonArray>
#include <QDialog>

class ClickableLabel;

class PowerupEditorDialog : public QObject
{
    Q_OBJECT
public:
    explicit PowerupEditorDialog(QObject *parent = nullptr);

    QHash<int, QJsonObject> slot_grids;
    QHash<int, QString> slot_targets;
    QHash<int, QString> slot_types;
    QHash<int,  int> slot_amounts;
    QHash<int, QString> slot_colors;
    QHash<int, int> slot_energy;
    QHash<int, QComboBox*> slot_targets_combos;
    QHash<int, QComboBox*> slot_types_combos;
    QHash<int, QComboBox*> slot_colors_combos;
    QHash<int, QSpinBox*> slot_amounts_spins;
    QHash<int, QSpinBox*> slot_energy_spins;
    QHash<int, QWidget*> slot_grids_widgets;
    QDialog *dialog;
    template <typename T>
    T* getWidgetFromForm(QFormLayout *form, bool grab_second = false) {
       bool _gs = grab_second;
        for (int i = 0; i < form->count(); ++i) {
            if (_gs) { _gs = false; continue; }
            QWidget *widget = form->itemAt(i, QFormLayout::FieldRole)->widget();
            if (T* specificWidget = qobject_cast<T*>(widget)) {
                return specificWidget;
            }
        }
        return nullptr;
    }
    QJsonArray collectFormData(int slot_num);

    void loadPowerupsFromJSON();

    void updateWidgetsFromJSONArray(const QJsonArray &powerupsArray);
public slots:
    void showDialog();
    void updateEnergy(int slot_num = -1);
    void updateAllEnergy();
    Q_INVOKABLE void closeDialog();

signals:
    void toggleGridSelection(int slot_num, int row, int col);
    void signal_powerups_saved(QJsonArray powerup_data);
   void signalPowerupsLoaded();
};

#endif // POWERUPEDITORDIALOG_H
