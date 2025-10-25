#include "powerupeditordialog.h"
#include <QCoreApplication>
#include <QDir>
#include <QTimer>
#include <algorithm>
#include <cmath>
#include <QObject>
#include <QDialog>
#include <QLineEdit>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QFormLayout>
#include <QComboBox>
#include <QSpinBox>
#include <QAbstractSpinBox>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QFile>
#include <QHash>
#include "ClickableLabel.h"
#include <QtDebug>
#include <QString>
#include <QSpinBox>

#include <QJsonValue>

namespace {
int gridSelectionCount(const QJsonObject &grid) {
    int count = 0;
    for (auto it = grid.begin(); it != grid.end(); ++it) {
        if (it.value().toBool()) {
            ++count;
        }
    }
    return count;
}

int computeBalancedEnergy(const QString &type, int amount, int life, const QJsonObject &grid) {
    const int damage = std::abs(amount);
    const int coverage = std::max(0, gridSelectionCount(grid));
    double base = 0.0;
    if (type == QStringLiteral("blocks")) {
        base = static_cast<double>(damage) * std::max(1, coverage);
    } else if (type == QStringLiteral("health")) {
        base = static_cast<double>(damage) * 2.5;
    } else if (type == QStringLiteral("heros") || type == QStringLiteral("heroes")) {
        base = static_cast<double>(damage) * 1.5;
    } else {
        base = static_cast<double>(damage);
    }
    const double lifeBonus = std::max(0, life) * 0.4;
    int energy = static_cast<int>(std::round(base + lifeBonus));
    if (energy == 0 && damage > 0) {
        energy = 1;
    }
    return energy;
}
}

PowerupEditorDialog::PowerupEditorDialog(QObject* parent) : QObject(parent)
{
    // Dialog setup can go here
    dialog = new QDialog(nullptr);
    showDialog();
}

void PowerupEditorDialog::showDialog()
{
dialog->open();

    QVBoxLayout *mainLayout = new QVBoxLayout(dialog);
    QHBoxLayout *horizontalLayout = new QHBoxLayout;

    auto createGrid = [&](int slot_num) -> QWidget* {
            QGridLayout *grid = new QGridLayout;
            QJsonObject gridObj;
            for (int row = 0; row < 6; ++row) {
        for (int col = 0; col < 6; ++col) {
            QLabel *cell = new QLabel;
            gridObj.insert(QString("%1").arg((row * 6) + col), QJsonValue(false));
            cell->setFixedSize(20, 20);
            if (this->slot_grids.value(slot_num).value(QString("%1").arg((row * 6) + col)).toBool() == false) {
            cell->setStyleSheet("border: 1px solid black; background-color: lightgray;");
            } else  {
                cell->setStyleSheet("border: 1px solid yellow; background-color: lightgray;");
            }

            // Toggle state on click
            cell->installEventFilter(new ClickableLabel(cell, [this, cell, row, col, slot_num]() {
                if (cell->styleSheet() == "border: 1px solid black; background-color: lightgray;") {
                    cell->setStyleSheet("border: 1px solid yellow; background-color: lightgray;");
                    QJsonObject obj = this->slot_grids.value(slot_num);
                    obj.insert(QString("%1").arg((row * 6) + col),true);
                    slot_grids[slot_num] = obj;
                } else {
                    cell->setStyleSheet("border: 1px solid black; background-color: lightgray;");
                    QJsonObject obj = this->slot_grids.value(slot_num);
                    obj.insert(QString("%1").arg((row * 6) + col),false);
                    slot_grids[slot_num] = obj;

                }}));

            connect(this, &PowerupEditorDialog::toggleGridSelection, cell, [this, cell, row, col, slot_num](int i, int r, int c) {
                          if (i == slot_num && r == row && c == col) {
                              // Update cell's stylesheet
                              if (cell->styleSheet() == "border: 1px solid black; background-color: lightgray;") {
                                  cell->setStyleSheet("border: 1px solid yellow; background-color: lightgray;");
                                  QJsonObject obj = this->slot_grids.value(slot_num);
                                  obj.insert(QString("%1").arg((row * 6) + col),true);
                                  slot_grids[slot_num] = obj;
                              } else {
                                  cell->setStyleSheet("border: 1px solid black; background-color: lightgray;");
                                  QJsonObject obj = this->slot_grids.value(slot_num);
                                  obj.insert(QString("%1").arg((row * 6) + col),false);
                                  slot_grids[slot_num] = obj;

                              }
                              this->updateEnergy(slot_num);
                          }

                      });
            grid->addWidget(cell, row, col);
        }
    }
            slot_grids[slot_num] = gridObj;
    QWidget *gridWidget = new QWidget;
    gridWidget->setLayout(grid);
    gridWidget->hide();
    return gridWidget;
};


auto populateForm = [&, this](QFormLayout *form, int slot_num) {
    if (slot_targets_combos.value(slot_num, nullptr) == nullptr) {
        QComboBox *targetBox = new QComboBox();
        targetBox->addItems({"self", "opponent"});
        form->addRow("Target Player:", targetBox);
        this->slot_targets_combos[slot_num] = targetBox;
    }
    slot_targets_combos.value(slot_num)->setCurrentText(this->slot_targets.value(slot_num));

    QComboBox *typeBox = new QComboBox();
    typeBox->addItems({"blocks", "health", "heros"});
    form->addRow("Type:", typeBox);
    this->slot_types_combos[slot_num] = typeBox;
   typeBox->setCurrentText(this->slot_types.value(slot_num));

    QComboBox *colorBox = new QComboBox();
    colorBox->addItems({"red", "green", "blue", "yellow"});
    form->addRow("Color:", colorBox);
    this->slot_colors_combos[slot_num] = colorBox;
    colorBox->setCurrentText(this->slot_colors.value(slot_num));

    QSpinBox *amountBox = new QSpinBox();
    amountBox->setRange(-200, 200);
    form->addRow("Amount:", amountBox);
    this->slot_amounts_spins[slot_num] = amountBox;
    amountBox->setValue(this->slot_amounts.value(slot_num));
    slot_amounts[slot_num] = amountBox->value();

    QSpinBox *lifeBox = new QSpinBox();
    lifeBox->setRange(0, 2000);
    lifeBox->setSingleStep(10);
    form->addRow("Life:", lifeBox);
    this->slot_life_spins[slot_num] = lifeBox;
    lifeBox->setValue(this->slot_life.value(slot_num, 0));
    slot_life[slot_num] = lifeBox->value();

    QSpinBox *energyBox = new QSpinBox();
    energyBox->setRange(0, 4000);
    energyBox->setReadOnly(true);
    energyBox->setButtonSymbols(QAbstractSpinBox::NoButtons);
    form->addRow("Energy:", energyBox);
    this->slot_energy_spins[slot_num] = energyBox;
    //updateEnergy(slot_num);
    energyBox->setValue(this->slot_energy.value(slot_num));

    QWidget *gridWidget = createGrid(slot_num);
    form->addRow(gridWidget);
    gridWidget->show();
    this->slot_grids_widgets[slot_num] = gridWidget;

    QObject::connect(typeBox, &QComboBox::currentTextChanged, [=](const QString &text) {
        if (text == "blocks") {
            gridWidget->show();
        } else {
            gridWidget->hide();
        }
        slot_types[slot_num] = text;
        this->updateEnergy(slot_num);
    });

    QObject::connect(amountBox, QOverload<int>::of(&QSpinBox::valueChanged), [=](const int value) {
        slot_amounts[slot_num] = value;
        this->updateEnergy(slot_num);
    });

    QObject::connect(lifeBox, QOverload<int>::of(&QSpinBox::valueChanged), [=](const int value) {
        slot_life[slot_num] = value;
        this->updateEnergy(slot_num);
    });

};

QGroupBox *_slots[4] = {new QGroupBox("Slot 1"), new QGroupBox("Slot 2"), new QGroupBox("Slot 3"), new QGroupBox("Slot 4")};
for (int i=0; i<4; i++) {
    QFormLayout *form = new QFormLayout;
    populateForm(form, i);
    QGroupBox *_slot = _slots[i];
    _slot->setLayout(form);
    horizontalLayout->addWidget(_slot);

}


mainLayout->addLayout(horizontalLayout);

QDialogButtonBox buttonBox(QDialogButtonBox::Ok | QDialogButtonBox::Cancel);
connect(&buttonBox, &QDialogButtonBox::accepted, dialog, &QDialog::accept);
connect(&buttonBox, &QDialogButtonBox::rejected, dialog, &QDialog::reject);

mainLayout->addWidget(&buttonBox);

QPushButton *saveButton = new QPushButton("Save");

mainLayout->addWidget(saveButton);
connect(saveButton, &QPushButton::clicked, [&]() {
    QJsonArray totalArray;
    for (int i=0; i<4; i++) {
        int slot_num = i;
        updateEnergy(slot_num);

        totalArray.append(collectFormData(slot_num));
        qDebug() << slot_num << qCompress(QJsonDocument(collectFormData(slot_num)).toJson(QJsonDocument::Compact), 9).toBase64();

    }

    QJsonDocument doc(totalArray);
QFile file(qApp->applicationDirPath().append(QDir::separator()).append("powerups.json"));
    if (file.open(QIODevice::WriteOnly)) {
        file.write(doc.toJson(QJsonDocument::Compact));
        file.close();
    }
    emit this->signal_powerups_saved(totalArray);
    qDebug() << qCompress(doc.toJson(QJsonDocument::Compact), 8).toBase64();
});



dialog->repaint();
QTimer::singleShot(1000, this, &PowerupEditorDialog::loadPowerupsFromJSON);
qDebug() << this->slot_types.values();
qDebug() << this->slot_grids.values();
qDebug() << this->slot_types_combos.values();

}

void PowerupEditorDialog::updateEnergy(int slot_num)
{
    if (slot_num < 0) {
        for (auto it = slot_types_combos.begin(); it != slot_types_combos.end(); ++it) {
            updateEnergy(it.key());
        }
        return;
    }
    if (!slot_types_combos.contains(slot_num) || !slot_amounts_spins.contains(slot_num) || !slot_energy_spins.contains(slot_num)) {
        return;
    }

    QString slotType = slot_types_combos.value(slot_num)->currentText();
    int amount = slot_amounts_spins.value(slot_num)->value();
    int life = slot_life_spins.contains(slot_num)
            ? slot_life_spins.value(slot_num)->value()
            : slot_life.value(slot_num, 0);
    QJsonObject grid = slot_grids.value(slot_num, QJsonObject());

    slot_types[slot_num] = slotType;
    slot_amounts[slot_num] = amount;
    slot_life[slot_num] = life;

    slot_energy[slot_num] = computeBalancedEnergy(slotType, amount, life, grid);
    slot_energy_spins.value(slot_num)->setValue(slot_energy.value(slot_num));
}

void PowerupEditorDialog::updateAllEnergy()
{
    updateEnergy(-1);
    QTimer::singleShot(300, this, &PowerupEditorDialog::updateAllEnergy);
}

void PowerupEditorDialog::closeDialog()
{
dialog->reject();
}
QJsonArray PowerupEditorDialog::collectFormData(int slot_num) {
    QJsonArray jsonArray;

    QComboBox *targetBox = this->slot_targets_combos.value(slot_num);
    QComboBox *typeBox =  this->slot_types_combos.value(slot_num);
    QSpinBox *amountBox =  this->slot_amounts_spins.value(slot_num);
    QSpinBox *energyBox =  this->slot_energy_spins.value(slot_num);
    QComboBox *colorBox = this->slot_colors_combos.value(slot_num);

    QWidget *grid = this->slot_grids_widgets.value(slot_num);

    if (!targetBox) {

        targetBox = new QComboBox;
        targetBox->addItems({"self", "opponent"});


    }
    if (!typeBox) {
        typeBox = new QComboBox();
        typeBox->addItems({"blocks", "health", "heros"});
    }
    updateEnergy(slot_num);
    QJsonObject slotObject;
    slotObject["target"] = targetBox->currentText();
    slotObject["type"] = typeBox->currentText();
    slotObject["amount"] = amountBox->value();
    slotObject["color"] = colorBox->currentText();
    slotObject["grid"] = slot_grids.value(slot_num);
    slotObject["life"] = slot_life.value(slot_num, slot_life_spins.contains(slot_num) ? slot_life_spins.value(slot_num)->value() : 0);
    slotObject["energy"] = slot_energy.value(slot_num);







    jsonArray.append(slotObject);
    return jsonArray;
}
void PowerupEditorDialog::loadPowerupsFromJSON() {
    // Read JSON file
    QFile file(qApp->applicationDirPath().append(QDir::separator()).append("powerups.json"));
    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "Cannot open file";
        // Handle error
        return;
    }
    QByteArray jsonData = file.readAll();
    file.close();

    // Parse JSON data
    QJsonDocument document = QJsonDocument::fromJson(jsonData);
    QJsonArray powerupsArray = document.array();
    qDebug() << powerupsArray;
    // Loop through the array and populate the QHash objects
    for (int i = 0; i < powerupsArray.count(); ++i) {
        QJsonObject powerupObject = powerupsArray.at(i).toObject();

        // Populate slot_grids
        slot_grids[i] = powerupObject.value("grid").toObject();

        // Populate slot_targets
        slot_targets[i] = powerupObject.value("target").toString();

        // Populate slot_types
        slot_types[i] = powerupObject.value("type").toString();

        // Populate slot_amounts
        slot_amounts[i] = powerupObject.value("amount").toInt();

        // Populate slot_colors
        slot_colors[i] = powerupObject.value("color").toString();

        // Populate slot_energy
        slot_energy[i] = powerupObject.value("energy").toInt();

        // Populate slot_life
        slot_life[i] = powerupObject.value("life").toInt();

        // Populate UI elements if they exist



    }
    updateWidgetsFromJSONArray(powerupsArray);
    updateAllEnergy();
    emit this->signalPowerupsLoaded();
}

void PowerupEditorDialog::updateWidgetsFromJSONArray(const QJsonArray &powerupsArray) {
    // Error check: Validate that JSON array is not empty
    if (powerupsArray.isEmpty()) {
        // Handle error: JSON array is empty
        return;
    }

    // Loop through the JSON array and update widgets
    for (int i = 0; i < powerupsArray.size(); ++i) {
        QJsonArray slotArray = powerupsArray[i].toArray();

        // Error check: Validate that each slot is an array and not empty
        if (slotArray.isEmpty()) {
            // Handle error: Slot array is empty
            continue;
        }

        QJsonObject powerupObject = slotArray[0].toObject();

        // Update QHash objects and widgets if they exist
        if (slot_targets_combos.contains(i)) {
            QString target = powerupObject.value("target").toString();
            slot_targets_combos[i]->setCurrentText(target);
        }

        if (slot_types_combos.contains(i)) {
            QString type = powerupObject.value("type").toString();
            slot_types_combos[i]->setCurrentText(type);
        }

        if (slot_colors_combos.contains(i)) {
            QString color = powerupObject.value("color").toString();
            slot_colors_combos[i]->setCurrentText(color);
        }

        if (slot_amounts_spins.contains(i)) {
            int amount = powerupObject.value("amount").toInt();
            slot_amounts_spins[i]->setValue(amount);
        }

        if (slot_energy_spins.contains(i)) {
            int energy = powerupObject.value("energy").toInt(0);  // Default value is 0
            slot_energy_spins[i]->setValue(energy);
        }
        if (slot_life_spins.contains(i)) {
            int life = powerupObject.value("life").toInt(0);
            slot_life_spins[i]->setValue(life);
            slot_life[i] = life;
        }
        QJsonObject jsonObj = powerupObject.value("grid").toObject();
        for (const QString& key : jsonObj.keys()) {
            QJsonValue value = jsonObj.value(key);

            // Convert the key to an integer index
            int index = key.toInt();

            // Calculate row and col based on index
            int row = index / 6;
            int col = index % 6;

            // Emit the signal based on the value
            if (value.toBool()) {
                emit toggleGridSelection(i, row, col);  // Assuming slot_num is known
            }
        }
        // Add more widget updates as needed
        updateEnergy(i);
    }
}
