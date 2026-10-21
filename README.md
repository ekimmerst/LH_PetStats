# LH_PetStats

Version: 1.0.1

WoW Forever Beta, Interface 16001. Requires LH_Tweaks; no settings are needed.

The loyalty bar uses LH_ExpBar's texture, gold color, and border. It is 10 UI pixels high (half of LH_ExpBar), matches the pet mana bar's width, aligns with its right edge, and starts 8 UI pixels above PetFrame's bottom edge. The text to the left of the portrait shows current / maximum loyalty rank and progress in a 10-pixel font with 5 pixels of additional line spacing.

Loyalty uses the method inspected in NetherPetXP (`PetXPForever/Core/Pet.lua` and `UI/Panel.lua`): resolve the localized or English rank name (or an embedded rank number) and fill the bar with current rank / 6. For example, rank 3/6 displays 50%, rank 6/6 displays 100%. This percentage describes the attained rank, not progress toward the next rank; neither NetherPetXP nor the beta API provides that progress. The tooltip explains this distinction. Pet experience and happiness are not used as substitutes. Unknown ranks show `? / 6` and `-- %`. Only hunter pets with loyalty data are shown; visibility follows PetFrame. No NetherPetXP dependency is required.

API reference: https://raw.githubusercontent.com/Gethe/wow-ui-source/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/PetInfoDocumentation.lua

After installation, restart the client if LH_PetStats is not yet listed, then enable the addon. In-game positioning and visibility still need verification in the beta client.

## Installation and upgrade

Place the `LH_PetStats` folder in your game's `Interface/AddOns` folder. It must contain `LH_PetStats.toc`, `LH_PetStats.lua` and the bundled `Media` folder. Restart WoW and enable **LH_PetStats** in the AddOns list.

When upgrading from MiniPetStats, replace the old folder and fully restart WoW. Do not enable both versions together. There are no saved settings to migrate and no slash commands.

## Changelog

### 1.0.1 - 2026-10-21

- Renamed MiniPetStats to LH_PetStats, including its folder, Lua/TOC filenames, metadata, texture path, named frames and verification-script references.
- Updated English documentation and references to the renamed LH_ExpBar addon.
- Loyalty display behavior and existing localized tooltips are unchanged.

## Required core addon

Install and enable **LH_Tweaks** alongside this addon. LH_Tweaks is the shared LiteHawk configuration host and must load first. CurseForge releases must list LH_Tweaks as a required dependency so the client installs it automatically.
