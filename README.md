# auto-display-manager-cr

A rewrite of my Ruby script for automatic management of multiple screens (displays) using XRandR in Crystal.

## Dependencies

* crystal 0.23.1
* xrandr (tested with 1.5)
* notify-send from libnotify (tested with 0.7.7) and notification daemon

## Installation

```
./build.sh
```
```
sudo (PREFIX=prefix, default /usr/local) ./install.sh
```

### Arch Linux
On Arch Linux you can install the package from AUR:
```
pacaur -S auto-display-manager-cr-git
```

## Usage

For usage instructions go to https://github.com/Phitherek/auto-display-manager. This is almost a drop-in replacement. There is also a built-in help in each command.

## Contribution

Issues and pull requests are welcome.

Enjoy!
