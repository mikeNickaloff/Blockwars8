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

- Install Qt 5.15.2+ (LTS)

- Clone the repository
```
git clone https://github.com/mikeNickaloff/Blockwars8.git
```

## Build and Install

Prerequisites
- Qt 5.15.2+ with modules: `qml`, `quick`, `quickcontrols2`, `websockets`, `widgets`, `gui`, `network`, and build tools (`qmake`, `Qt Creator`).
- Ensure you use the `qmake` from your Qt 5.15.x install, not a system `qmake` from another version.

Build with Qt Creator (all platforms)
- Open `Blockwars8.pro` in Qt Creator.
- Select a Qt 5.15.x kit (e.g., Desktop Qt 5.15.2 MSVC/MinGW/macOS/Linux).
- Configure, then Build and Run. Qt Creator will handle include paths and QML import paths.

Build via CLI
- Linux (Debian/Ubuntu)
  - Install dependencies:
    - `sudo apt update`
    - `sudo apt install -y qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev qml-module-qtquick-controls2 qml-module-qtquick2 qml-module-qtquick-layouts qtwebsockets5-dev qml-module-qtwebsockets qttools5-dev`
  - Build:
    - `mkdir -p build && cd build`
    - `qmake ..`
    - `make -j"$(nproc)"`
  - Run: `./Blockwars8`
- Linux (Fedora/RHEL)
  - `sudo dnf install -y qt5-qtbase-devel qt5-qtdeclarative-devel qt5-qtquickcontrols2-devel qt5-qtwebsockets-devel qt5-qttools-devel`
  - Build: same as Debian (use `qmake .. && make -j$(nproc)`) and run `./Blockwars8`.
- Linux (Arch)
  - `sudo pacman -S --needed qt5-base qt5-declarative qt5-quickcontrols2 qt5-websockets qt5-tools`
  - Build: `mkdir build && cd build && qmake .. && make -j"$(nproc)"` and run `./Blockwars8`.
- macOS
  - Install Qt 5.15.x:
    - Homebrew: `brew install qt@5` (qmake at `/usr/local/opt/qt@5/bin/qmake` or `/opt/homebrew/opt/qt@5/bin/qmake` on Apple Silicon).
    - Or use the Qt Online Installer and select Qt 5.15.2.
  - Build:
    - `mkdir build && cd build`
    - `"$(brew --prefix qt@5 2>/dev/null || true)/bin/qmake" ..` (or the qmake path from your Qt install)
    - `make -j"$(sysctl -n hw.ncpu)"`
  - Run: `open Blockwars8.app` (binary at `Blockwars8.app/Contents/MacOS/Blockwars8`).
- Windows (MSVC)
  - Open the "Qt 5.15.2 for MSVC <arch>" command prompt from the Qt installation.
  - Build:
    - `mkdir build && cd build`
    - `qmake ..`
    - `nmake` (or `jom` if installed)
  - Run: `release\Blockwars8.exe` or `debug\Blockwars8.exe`.
- Windows (MinGW)
  - Open the "Qt 5.15.2 (MinGW)" command prompt.
  - Build:
    - `mkdir build && cd build`
    - `qmake ..`
    - `mingw32-make -j%NUMBER_OF_PROCESSORS%`
  - Run: `release\Blockwars8.exe` or `debug\Blockwars8.exe`.

Install / Package
- Linux/macOS install target: `make install` (uses `deployment.pri`; on Unix installs to `/opt/Blockwars8/bin` by default unless overridden).
- Windows packaging: `windeployqt path\to\Blockwars8.exe` to bundle required Qt and QML modules.
- macOS packaging: `macdeployqt Blockwars8.app -qmldir=..` to bundle Qt frameworks and QML imports.

Troubleshooting
- Unknown module(s) in QT: quickcontrols2, websockets: install the corresponding `-dev` packages (Linux) or select these modules in your Qt kit.
- QML import not found (Qt Quick Controls 2): install runtime packages like `qml-module-qtquick-controls2` (Debian/Ubuntu) or `qt5-quickcontrols2` (Arch/Fedora).
- Wrong qmake in PATH (Qt 6 detected): use the Qt 5.15.x kit’s `qmake` explicitly (full path) or adjust your environment to point to Qt 5.15.x.
