# Corne ZMK Keymap

![Keymap](corne_keymap.svg)

Split ergonomic keyboard (42 keys) running [ZMK firmware](https://zmk.dev) on Nice!Nano v2.

## Layers

| # | Layer | Thumb Key | Description |
|---|-------|-----------|-------------|
| 0 | base  | -         | QWERTY + home row mods |
| 1 | media | Hold ESC  | RGB, Bluetooth, volume |
| 2 | sym   | Hold ENTER| Symbols `{ } $ % ^ & *` |
| 3 | num   | Hold BSPC | Number pad + math ops |
| 4 | nav   | Hold SPACE| Arrows, clipboard, PgUp/Dn |
| 5 | fun   | Hold DEL  | F1-F12 |
| 6 | mouse | Hold TAB  | Mouse movement + clicks |

## RGB LEDs

Hold **ESC** (left thumb) to enter the media layer, then:

| Key | Function |
|-----|----------|
| Y   | RGB Toggle (on/off) |
| U   | RGB Effect (cycle animations) |
| I   | RGB Hue+ |
| O   | RGB Saturation+ |
| P   | RGB Color preset (purple) |
| H   | External Power Toggle |

## Home Row Mods

Hold the home row key instead of tapping:

| Key | Tap | Hold |
|-----|-----|------|
| A   | a   | Cmd  |
| S   | s   | Opt  |
| D   | d   | Ctrl |
| F   | f   | Shift|
| J   | j   | Shift|
| K   | k   | Ctrl |
| L   | l   | Opt  |
| ;   | ;   | Cmd  |

## Combos

Press both keys simultaneously:

| Keys | Output |
|------|--------|
| E+R  | `[`    |
| U+I  | `]`    |
| D+F  | `(`    |
| K+L  | `)`    |
| C+V  | `{`    |
| ,+.  | `}`    |
| T+Y  | `\`    |
| G+H  | `\|`   |

## Interactive Viewer

Open the HTML keymap viewer locally:

```sh
make viewer
```

Press `?` to open the cheat sheet. Press `0-6` to switch layers.

## Build Firmware

Push to `config/` triggers the [Build ZMK firmware](.github/workflows/build.yml) workflow. Download the `.uf2` files from the Actions artifacts.

## Regenerate Keymap SVG

Runs automatically on push via [Draw Keymap](.github/workflows/draw-keymap.yml), or locally:

```sh
make install   # one-time: pip install keymap-drawer
make svg       # parse + render SVG
```

## Hardware

- **Board:** Nice!Nano v2 (nRF52840)
- **Shield:** Corne (split, 6x3+3)
- **Display:** OLED SSD1306 / Nice!View
- **RGB:** 27 WS2812 LEDs, 60% max brightness
- **Bluetooth:** 4 profiles, +8dBm TX power
- **ZMK Studio:** Enabled
