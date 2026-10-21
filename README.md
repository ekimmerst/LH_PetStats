# LH_PetStats

Version: 1.1.0

WoW Forever Beta, Interface 16001. Requires LH_Tweaks.

The loyalty bar uses LH_ExpBar's texture, gold color, and border. It is 10 UI pixels high, matches the pet mana bar's width, aligns with its right edge, and starts 8 UI pixels above PetFrame's bottom edge. Text to the left of the portrait shows only current / maximum loyalty rank, such as `4 / 6`, in a 10-point font. The former percentage line is removed.

The rank text inherits the font flags and shadow from Blizzard's `ObjectiveTrackerLineFont`, the font used for individual quest objectives, while keeping its original 10-point size. This replaces the explicitly added OUTLINE plus shadow. GameFontHighlightSmall is used until the tracker font is available; loading the tracker updates the style automatically. Reference: [Forever objective line template](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ObjectiveTracker/Blizzard_ObjectiveTrackerShared.xml).

Loyalty uses the method inspected in NetherPetXP (`PetXPForever/Core/Pet.lua` and `UI/Panel.lua`): resolve the localized or English rank name (or an embedded rank number) and fill the bar with current rank / 6. For example, rank 3/6 fills half the bar and rank 6/6 fills it completely. This describes the attained loyalty rank, not pet XP or progress toward the next rank; neither NetherPetXP nor the beta API provides that within-rank progress. The tooltip explains this distinction. Pet experience and happiness are not used as substitutes. Unknown ranks show `? / 6` with an empty bar. Only hunter pets with loyalty data are shown; visibility follows PetFrame. No NetherPetXP dependency is required.

## Options

Open WoW Settings > AddOns > LH Tweaks > LH PetStats, or type `/lh_petstats`. The native page has a main **Enable pet loyalty information** checkbox, plus independent **Show the loyalty bar** and **Show the loyalty rank** controls. All three default to enabled and are saved per character in `LH_PetStatsDB`. Disabling hides the addon and its tooltip immediately; reenabling refreshes the display. Child preferences remain saved while disabled. Native Defaults restores all three options. Use `/lh_petstats on` or `/lh_petstats off` to toggle the main setting directly.

API reference: https://raw.githubusercontent.com/Gethe/wow-ui-source/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/PetInfoDocumentation.lua

After installation, restart the client if LH_PetStats is not yet listed, then enable the addon. In-game positioning and visibility still need verification in the beta client.

## Installation and upgrade

Place the complete `LH_PetStats` folder in your game's `Interface/AddOns` folder, including LH_PetStats.toc, LH_PetStats.lua, Settings.lua and Media. Install and enable LH_Tweaks as well. Fully restart WoW and enable **LH PetStats**, grouped under **LH Tweaks**, in the AddOns list. Version 1.1.0 needs a full restart because its TOC adds settings, saved-variable, grouping and icon metadata.

When upgrading from MiniPetStats, replace the old folder and fully restart WoW. Do not enable both versions together. Versions before 1.1.0 had no saved settings to migrate.

The shared addon-list icon is bundled as Media/Icon.png and Media/Icon.tga, byte-identical copies of LH_Tweaks' gold LH artwork, using Spoken's chamfered gold frame as the reference. There is no runtime Spoken dependency.

## Verification

`.settings-test.py` and the updated `.verify.lua` passed Lua 5.1 simulations for native module registration, all three settings/defaults, immediate toggles, independent bar/rank visibility, removed percentage text, quest-objective font/shadow inheritance including late tracker loading, tooltip ownership/cleanup, localized/English/unknown loyalty ranks, restricted/error data, hunter/pet conditions and existing bar positioning/fill. Shared icon files are checked byte-for-byte against LH_Tweaks; `git diff --check` passed.

Run `python LH_PetStats/.settings-test.py` from the AddOns folder with Lupa available in `LH_Tweaks/.test-runtime`. In-game layout and native rendering remain pending: fully restart WoW, inspect the shorter rank text and lighter tracker-style shadow, exercise the three controls and check settings after `/reload`.

## Changelog

### 1.1.0 - 2026-10-21

- Added native LH PetStats settings under LH Tweaks with an activation switch and separate loyalty-bar/rank-text controls, all enabled by default and saved per character.
- Added `/lh_petstats` to open settings and `on|off` for immediate toggling.
- Removed the percentage line beside the pet portrait; retained the loyalty rank and rank-based bar fill.
- Replaced the explicit outlined rank text with the quest objective font's flags and shadow, keeping its 10-point size.
- Added the shared LH icon and native AddOn list grouping under LH Tweaks.

### 1.0.1 - 2026-10-21

- Renamed MiniPetStats to LH_PetStats, including its folder, Lua/TOC filenames, metadata, texture path, named frames and verification-script references.
- Updated English documentation and references to the renamed LH_ExpBar addon.
- Loyalty display behavior and existing localized tooltips are unchanged.

## Required core addon

Install and enable **LH_Tweaks** alongside this addon. LH_Tweaks is the shared LiteHawk configuration host and must load first. CurseForge releases must list LH_Tweaks as a required dependency so the client installs it automatically.
