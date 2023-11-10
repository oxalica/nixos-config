{ telegram-desktop, qtwayland-fix-freeze }:
telegram-desktop.override {
  qtwayland = qtwayland-fix-freeze;
}
