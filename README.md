# Blockwars 8

## what is Block Wars?
- Block Wars is a cross-platform game that allows players to battle it out in a duel-style match-3 game where the matches you make turn into projectiles that damage the enemy's isolated match-3 game. 
- Players take turns alternating between being on offense and on defense.  
- Each player gets three moves on offense, then has to defend against three moves on defense.
- Offensive players make matches within their match-3 grid to attack the other player's blocks. 
- Also features Powerup Card system that lets players customize various types of Powerups by adjusting the damage, targets, colors, and more.
- Players can use their custom powerups to battle other players online against other player's Powerup Cards. 
- Each player gets 4 cards per game, and they must be charged up by destroying oppponent's blocks of the same color as the Powerup cards.
- Once cards are charged, you must place them somewhere on your game board where they will be exposed to attacks from blocks and powerup cards
- Depending on the amount of life your Powerup Card has and the amount of damage it does, activation energy is automatically calculated, so there are many variations of Cards that will be brought to battles.
- Single player mode vsersus A.I. is also available. 
- While on offense, player's blocks automatically fill in and cascade by launching matches at the opponent's board.
- Matches are only launched when the offensive player's board is totally filled.  
- Aside from the automatically launched matches, you have three moves on offense to move your blocks by swapping any single block one cell in any direction (up,down, left, or right). 
- After swapping, any matching row or column of three or more connected blocks of the same color will activate and launch at the opponent's match-3 grid.  
- Destroy an entire column of the opponent's blocks within 3 moves and any blocks that are fired at empty columns will deal direct damage to the enemy player's health. 
- First player to run out of health loses the game. 
- Winners gain more Total Powerup Energy available to them so that they can increase their Powerup Cards' attributes.

## Installation

### Install Qt 5.15.2+ (LTS)
Use Qt 5.15.x, not Qt 6. Ensure required modules are installed: qml, quick, quickcontrols2, websockets, widgets, gui, network.

### Clone the repository
```
git clone https://github.com/mikeNickaloff/Blockwars8.git
cd Blockwars8
```

## Build and Install

### Qt Creator (all platforms)
```
1) Open Blockwars8.pro in Qt Creator
2) Select a Desktop Qt 5.15.x kit
3) Configure the project
4) Build the project
5) Run (Qt Creator sets QML import paths automatically)
```

### Linux (Ubuntu/Debian)

#### Install dependencies
```
sudo apt update
sudo apt install -y \
  qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev \
  qml-module-qtquick-controls2 qml-module-qtquick2 qml-module-qtquick-layouts \
  qtwebsockets5-dev qml-module-qtwebsockets qttools5-dev
```

#### Build and run
```
mkdir -p build && cd build
qmake ..
make -j"$(nproc)"
./Blockwars8
```

### Linux (Fedora/RHEL)

#### Install dependencies
```
sudo dnf install -y qt5-qtbase-devel qt5-qtdeclarative-devel \
  qt5-qtquickcontrols2-devel qt5-qtwebsockets-devel qt5-qttools-devel
```

#### Build and run
```
mkdir -p build && cd build
qmake ..
make -j"$(nproc)"
./Blockwars8
```

### Linux (Arch)

#### Install dependencies
```
sudo pacman -S --needed qt5-base qt5-declarative qt5-quickcontrols2 qt5-websockets qt5-tools
```

#### Build and run
```
mkdir -p build && cd build
qmake ..
make -j"$(nproc)"
./Blockwars8
```

### macOS

#### Install Qt 5.15.x
```
# With Homebrew
brew install qt@5
# Or use the Qt Online Installer and select Qt 5.15.2
```

#### Build and run
```
mkdir -p build && cd build
"$(brew --prefix qt@5 2>/dev/null || true)/bin/qmake" ..
make -j"$(sysctl -n hw.ncpu)"
open Blockwars8.app
# Binary inside: Blockwars8.app/Contents/MacOS/Blockwars8
```

### Windows (MSVC)

#### Open the Qt MSVC command prompt
```
Start Menu → Qt → Qt 5.15.2 → Qt 5.15.2 for MSVC <arch>
```

#### Build and run
```
mkdir build && cd build
qmake ..
nmake   # or jom
release\Blockwars8.exe   # or debug\Blockwars8.exe
```

### Windows (MinGW)

#### Open the Qt MinGW command prompt
```
Start Menu → Qt → Qt 5.15.2 → Qt 5.15.2 (MinGW)
```

#### Build and run
```
mkdir build && cd build
qmake ..
mingw32-make -j%NUMBER_OF_PROCESSORS%
release\Blockwars8.exe   # or debug\Blockwars8.exe
```

## Packaging

### Linux/macOS install target
```
make install
# Default install path on Unix per deployment.pri:
#   /opt/Blockwars8/bin (override via qmake variables if desired)
```

### Windows deployment
```
windeployqt path\to\Blockwars8.exe
```

### macOS deployment
```
macdeployqt Blockwars8.app -qmldir=..
```

## Troubleshooting

### Unknown module(s) in QT (e.g., quickcontrols2, websockets)
Install the corresponding development packages on Linux or ensure your Qt kit includes these modules.

### QML import not found (Qt Quick Controls 2)
On Debian/Ubuntu, install runtime packages like:
```
sudo apt install qml-module-qtquick-controls2
```
On Arch/Fedora, ensure quickcontrols2 is installed.

### Wrong qmake in PATH (Qt 6 detected)
Use the Qt 5.15.x kit’s qmake explicitly by path, or adjust your environment so `qmake` resolves to Qt 5.15.x.
