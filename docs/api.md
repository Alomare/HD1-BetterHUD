# Better HUD for mod authors

Other mods reach Better HUD through `obsidian.import("alomare.betterhud")`.

`obsidian.import("alomare.betterhud").grenade_meter(unit, fraction)` shows a charge meter on the upper grenade icon of the card whose player avatar is `unit`: the icon at 30% opacity underneath, and the full icon over it, cut from the left to `fraction` (0 to 1) of the width. `nil` clears it, and a meter whose unit is gone is dropped. The meter works with the grenade counter on or off.

`obsidian.import("alomare.betterhud").flash_health(unit, seconds)` flashes the health bar of the card whose player avatar is `unit` white, fading out over `seconds` (2 when left out). It shows while the player health bars option is on.

`obsidian.import("alomare.betterhud").status_buildup(unit, kind, fraction, drain, icon)` shows how far a status has built up on an enemy, `"fire"`, `"poison"` or `"stun"`: the icon over the enemy health bar, white with a soft dark outline, filled from the bottom to `fraction` (0 to 1) in the color of the status. It fades in when it first shows. With `drain`, the fill runs down to empty over that many seconds, for a build-up that wears off or an effect running out, and the icon fades out at the end. `icon` is `{ art = material, uv = { u0, v0, u1, v1 } }` for an image a mod ships, or `{ icon = name }` for one of the game's; it is kept from the call before when left out, and a kind that never had one shows as a strip under the bar. `nil` clears it, and the entries of an enemy that is gone are dropped. It shows while the enemy health bars option is on and the enemy has a bar. Icons of several kinds sit side by side.

`obsidian.import("alomare.betterhud").elite_mark(unit, icon)` marks an enemy: its health bar shows from the start, at full health too, and stays while the enemy lives, with `icon` in the middle of the bar, white with the same soft dark outline as the status icons, standing well over the bar's top and bottom. `icon` takes the same forms as in `status_buildup`. `nil` clears the mark, and the bar then fades as any other; the mark of an enemy that is gone is dropped. Status icons over a marked bar sit clear of the mark. It shows while the enemy health bars option is on.

`obsidian.import("alomare.betterhud").status_effect(unit, kind, seconds, icon)` is the same as `status_buildup(unit, kind, 1, seconds, icon)`: an effect running for `seconds`, the icon full and running down. An effect shows only with an icon. 0 or `nil` seconds ends it.
