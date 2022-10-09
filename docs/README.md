[![Bank Panic Logo](bankp-logo.png)](#)

---

[![Active Development](https://img.shields.io/badge/Maintenance%20Level-Actively%20Developed-brightgreen.svg)](#status-of-features)
[![Build](https://github.com/opengateware/arcade-bankp/actions/workflows/build-pocket.yml/badge.svg)](https://github.com/opengateware/arcade-bankp/actions/workflows/build-pocket.yml)
[![release](https://img.shields.io/github/release/opengateware/arcade-bankp.svg)](https://github.com/opengateware/arcade-bankp/releases)
[![license](https://img.shields.io/github/license/opengateware/arcade-bankp.svg?label=License&color=yellow)](#legal-notices)
[![issues](https://img.shields.io/github/issues/opengateware/arcade-bankp.svg?label=Issues&color=red)](https://github.com/opengateware/arcade-bankp/issues)
[![stars](https://img.shields.io/github/stars/opengateware/arcade-bankp.svg?label=Project%20Stars)](https://github.com/opengateware/arcade-bankp/stargazers)
[![discord](https://img.shields.io/discord/676418475635507210.svg?logo=discord&logoColor=white&label=Discord&color=5865F2)](https://chat.raetro.org)
[![Twitter Follow](https://img.shields.io/twitter/follow/marcusjordan?style=social)](https://twitter.com/marcusjordan)

## Sanritsu / Sega [Bank Panic] Compatible Gateware IP Core

This Implementation of a compatible Bank Panic arcade hardware in HDL is the work of [Pierre Cornier].

## Overview

A reaction-based shoot-em-up in which the player takes on the role of a gun-slinging Deputy, who has been charged with protecting the town bank from outlaws.

## Technical specifications

- **Main CPU:**     Zilog Z80 @ 2.57808 MHz
- **Sound CPU:**    3x SN76489 @ 2.57808 MHz,
- **Resolution:**   224x224, 4096 colors
- **Aspect Ratio:** 1:1
- **Orientation:**  Horizontal

## Compatible Platforms

- Analogue Pocket

## Compatible Games

> **ROMs NOT INCLUDED:** By using this gateware you agree to provide your own roms.

| **Game**                        | Status |
| :------------------------------ | :----: |
| Bank Panic                      |   ✅   |
| Combat Hawk                     |   ✅   |

> Notes: Combat Hawk has some visual glitches but it's playable.

### ROM Instructions

1. Download and Install [ORCA](https://github.com/opengateware/tools-orca/releases/latest) (Open ROM Conversion Assistant)
2. Download the [ROM Recipes](https://github.com/opengateware/arcade-bankp/releases/latest) and extract to your computer.
3. Copy the required MAME `.zip` file(s) into the `roms` folder.
4. Inside the `tools` folder execute the script related to your system.
   1. **Windows:** right click `make_roms.ps1` and select `Run with Powershell`.
   2. **Linux and MacOS:** run script `make_roms.sh`.
5. After the conversion is completed, copy the `Assets` folder to the Root of your SD Card.
6. **Optional:** an `.md5` file is included to verify if the hash of the ROMs are valid. (eg: `md5sum -c checklist.md5`)

> **Note:** Make sure your `.rom` files are in the `Assets/bankp/common` directory.

## Status of Features

> **WARNING**: This repository is in active development. There are no guarantees about stability. Breaking changes might occur until a stable release is made and announced.

- [x] Dip Switches
- [ ] Pause
- [ ] Hi-Score Save

## Credits and acknowledgment

- [Daniel Wallner](https://opencores.org/projects/t80)
- [Guy Hutchison](https://github.com/hutch31)
- [Matthew Hagerty](https://github.com/dnotq)
- [Pierre Cornier]

## Support

Please consider showing your support for this and future projects by contributing to the developers. While it isn't necessary, it's greatly appreciated.

- IP Core Developer: [Pierre Cornier](https://www.patreon.com/pierco)
- OpenGateware Ports: [Marcus Andrade](https://www.paypal.com/donate/?hosted_button_id=N7HXKEL8VJ9CN)

## Powered by Open-Source Software

This project borrowed and use code from several other projects. A great thanks to their efforts!

| Modules                        | Copyright/Developer      |
| :----------------------------- | :----------------------- |
| [Bank Panic RTL]               | 2013 (c) Pierre Cornier  |
| [TV80]                         | 2004 (c) Guy Hutchison   |
| [SN76489]                      | 2020 (c) Matthew Hagerty |

## License

This work is licensed under multiple licenses.

- All original source code is licensed under [GNU General Public License v2.0 or later] unless implicit indicated.
- All documentation is licensed under [Creative Commons Attribution Share Alike 4.0 International] Public License.
- Some configuration and data files are licensed under [Creative Commons Zero v1.0 Universal].

Open Gateware and any contributors reserve all others rights, whether under their respective copyrights, patents, or trademarks, whether by implication, estoppel or otherwise.

Individual files may contain the following SPDX license tags as a shorthand for the above copyright and warranty notices:

```text
SPDX-License-Identifier: GPL-2.0-or-later
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-License-Identifier: CC0-1.0
```

This eases machine processing of licensing information based on the SPDX License Identifiers that are available at <https://spdx.org/licenses/>.

## Legal Notices

- Bank Panic © 1984 Sega. All rights reserved.
- Combat Hawk © 1987 Sega. All rights reserved.

The Open Gateware authors and contributors or any of its maintainers are in no way associated with or endorsed by Intel®, Altera®, AMD®, Xilinx®, Lattice®, Microsoft® or any other company not implicit indicated.
All other brands or product names are the property of their respective holders.

[Bank Panic]: https://en.wikipedia.org/wiki/Bank_Panic
[Bank Panic RTL]: https://github.com/MiSTer-devel/Arcade-BankPanic_MiSTer/tree/master/rtl
[TV80]: https://github.com/hutch31/tv80
[SN76489]: https://github.com/dnotq/sn76489_audio
[Pierre Cornier]: https://github.com/pcornier

[GNU General Public License v2.0 or later]: https://spdx.org/licenses/GPL-2.0-or-later.html
[Creative Commons Attribution Share Alike 4.0 International]: https://spdx.org/licenses/CC-BY-SA-4.0.html
[Creative Commons Zero v1.0 Universal]: https://spdx.org/licenses/CC0-1.0.html
