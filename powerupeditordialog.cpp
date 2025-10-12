#include "powerupeditordialog.h"
#include <QCoreApplication>
#include <QDir>
#include <QTimer>
#include "math.h"
#include <QObject>
#include <QDialog>
#include <QLineEdit>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QFormLayout>
#include <QComboBox>
#include <QSpinBox>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QFile>
#include <QHash>
#include "ClickableLabel.h"
#include <QtDebug>
#include <QString>
#include <QJsonValue>

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

    QSpinBox *energyBox = new QSpinBox();
    energyBox->setRange(-2000, 2000);
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

    QString slotType = this->slot_types_combos.value(slot_num)->currentText();
  //  qDebug() << "Updating energy for slot" << slot_num << slotType;
    if (slotType == "none") {


        slot_energy[slot_num] = 0;
    }
    slot_amounts[slot_num] = slot_amounts_spins.value(slot_num)->value();
    int amt = abs(this->slot_amounts.value(slot_num, 0));

//qDebug() << "amont is" << amt << "for energy calculation";

    // attacking only blocks therefore does not have possibility of killing player realistically
    //  because in order to make enough blocks to KO a player's 2000 health, you would need to first deal 2000 damage
    //  to blocks on the grid which will take long enough for the other player to fight back
    if (slotType == "blocks") {

        int gridSize = 0;
        for (int i=0; i<this->slot_grids.value(slot_num, QJsonObject()).keys().count(); i++) {
            QString key = this->slot_grids.value(slot_num).keys().at(i);
            if (this->slot_grids.value(slot_num, QJsonObject()).value(key).toBool() == true) {
                gridSize++;
             //   qDebug() << "grid size is now" << gridSize << "for energy calculation";
            }
        }
        this->slot_energy[slot_num] = amt * gridSize;


    }

    // direct player health damage, requires additional energy
    if (slotType == "health") {
        this->slot_energy[slot_num] = round(amt * 2.5);
    }

    // if energy kills a hero, it will spill over to the next random hero, then to the player's health
    // so this can be a bit smaller
    if (slotType == "heros") {
        this->slot_energy[slot_num] = round(amt * 1.5);
    }
    qDebug() << "Setting spinbox for slot" << slot_num << "energy to" << this->slot_energy.value(slot_num);
    this->slot_energy_spins.value(slot_num)->setValue(this->slot_energy.value(slot_num));



}

void PowerupEditorDialog::updateAllEnergy()
{
    updateEnergy(0);
    updateEnergy(1);
    updateEnergy(2);
    updateEnergy(3);
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
