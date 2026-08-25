# Pill Activities Switcher Widget

[![KDE Plasma 6](https://img.shields.io/badge/KDE_Plasma-6.0+-3152A0?style=for-the-badge&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![QML](https://img.shields.io/badge/UI-QML%2FQt6-41CD52?style=for-the-badge&logo=qt&logoColor=white)](https://doc.qt.io/qt-6/qtqml-index.html)
[![Category](https://img.shields.io/badge/Productivity-5AC8FA?style=for-the-badge&logo=workspace&logoColor=white)](https://github.com/PlasmaDrifter)
[![License](https://img.shields.io/badge/License-GPLv2-blue.svg?style=for-the-badge)](LICENSE)

A sleek, modern pill-shaped workspace Activity Switcher widget for KDE Plasma 6.

---

## Previews

![Pill Activities Switcher Animated Demo 1](screenshots/output.gif)
![Pill Activities Switcher Animated Demo 2](screenshots/output2.gif)
![Pill Activities Switcher Screenshot 1](screenshots/Screenshot_20260711_083426.png)
![Pill Activities Switcher Screenshot 2](screenshots/Screenshot_20260711_083453.png)

---

## Features

- **Pill-style**: visual switcher for KDE Plasma Activities
- **One-click**: switching between active activity spaces
- **Dynamic**: active state highlighting
- **Compact**: panel and desktop widget modes

## Requirements

- **Environment**: KDE Plasma 6.0 or higher
- **Framework**: Qt6 QML / Plasma Applet API

## Installation

### Option 1: Git Clone (Recommended)
```bash
mkdir -p ~/.local/share/plasma/plasmoids/
git clone https://github.com/PlasmaDrifter/Widget-Activity.Switcher.git ~/.local/share/plasma/plasmoids/local.widget.activities.switcher
```

### Option 2: Plasma Package Installer
```bash
kpackagetool6 -i ~/.local/share/plasma/plasmoids/local.widget.activities.switcher
```

Then right-click your desktop or panel $\rightarrow$ **Add Widgets...** and search for the widget name.

## Credits & License

- **Author / Maintainer**: PlasmaDrifter
- **License**: Licensed under the [GPLv2](LICENSE).
