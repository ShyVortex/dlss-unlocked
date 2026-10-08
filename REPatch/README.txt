================================================================================
REPATCH - PATCHED REFRAMEWORK (CAPCOM / RE ENGINE XeFG FIX)
================================================================================

This folder contains a patched version of REFramework (dinput8.dll) designed
to properly address Intel Xe Frame Generation (XeFG) issues and stutters in
Capcom / RE Engine titles.

PURPOSE:
--------
Capcom's RE Engine enforces strict memory and swapchain integrity checks.
This patched build of REFramework hooks early into the game engine, bypassing
integrity issues and properly resolving stutters and pacing problems when
using XeFG in Capcom titles.

INSTALLATION INSTRUCTIONS:
--------------------------
1. Copy "dinput8.dll" from this folder directly into your main game directory
   alongside the main game executable (.exe) and OptiScaler's "dxgi.dll".
2. Run the game as usual.

CREDITS & UPSTREAM:
-------------------
- REFramework fork by onehoon:
  https://github.com/onehoon/REFramework
- Original REFramework by praydog:
  https://github.com/praydog/REFramework

LICENSE:
--------
REFramework is licensed under the MIT License.
See Licenses/REFramework_LICENSE.txt for details.
