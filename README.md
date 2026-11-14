# Better HUD

More information on the HUD of HELLDIVERS (2015), for the [Obsidian](https://github.com/Alomare/ObsidianLauncher) mod manager.

Better HUD counts the rounds left in the magazine and the grenades on each player card, puts health and stamina bars under the player cards and health bars over enemies, and shows damage numbers where hits land. A reload circle and an ammo circle sit beside the Helldiver. Enemy bars show burns, poison and stuns, and wait at the edge of the screen while the enemy is out of view.

## How to use

Every part can be switched on or off in the options of Better HUD in Obsidian, or in game under **Mods → Better HUD** in the pause menu. A change in one place shows in the other.

## Known issues

- Players on other computers get no stamina bar: the game keeps stamina on each player's computer and never sends it.
- Lasers and arc weapons get no round counter, since they heat or charge up instead. The ammo circle shows their heat or charge.

Mod authors can add meters, flashes and status icons to the HUD through Better HUD: see [docs/api.md](docs/api.md).
