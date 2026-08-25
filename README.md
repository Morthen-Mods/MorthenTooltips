# BetterTooltip

**BetterTooltip** is a small, configurable tooltip addon for *Retail WoW*. It adds
the information the default tooltip leaves out and gets out of the way when the
game says it has to.

Available in **English** and **German**.

## Features

### General
- **Cursor anchoring** for most tooltips, on the left, center or right
- **Tooltip scaling** from 5% to 300%
- **Hide the health bar** on unit tooltips
- **Class coloring** for the name and class line of a hovered player
- **Hide in combat**, per tooltip type

### Extra information
- **IDs and icon file IDs** for units, spells, mounts, auras, items, toys,
  currencies, quests, macros and achievements
- **Player info** on hovered players: mount, target, Mythic+ score, guild rank,
  realm language and item level
- **Group finder language**: the language of a group's leader on its tooltip, and
  a flag next to every applicant

Everything is off by default except the general options; pick what you want in
*Options → AddOns → BetterTooltip*.

## Secret values

Since patch 12.0 the game hands addons *secret* values for anything it does not
want automated, and a secret cannot be compared, concatenated or used as a table
key without raising a Lua error. Every value BetterTooltip reads goes through a
single guard first. When a value is secret the line it would have filled is left
out, so inside instances and rated content the addon quietly shows less rather
than erroring or guessing.

## Layout

| File | What lives there |
| --- | --- |
| `Core.lua` | Settings, defaults, the secret guard, startup |
| `Realms.lua` | Realm to language data and lookup |
| `Tooltip.lua` | Anchoring, scaling, health bar, ID lines |
| `Unit.lua` | Everything on a unit tooltip, including the item level fetch |
| `GroupFinder.lua` | Group finder language and flags |
| `Options.lua` | The options panel |
| `Locales/` | `enUS.lua` is the base, `deDE.lua` overrides what it translates |

## Translating

Copy `Locales/enUS.lua` to `Locales/<locale>.lua`, keep the guard at the top,
translate the keys you want and add the file to the `.toc`. Anything you leave
out falls back to English.
