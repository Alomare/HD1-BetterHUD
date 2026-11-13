# Changelog

New, changed, fixed or removed features, one line each, brief and direct. The section for a release becomes the release notes.

## 1.17.1

- Changed the reload and ammo circles in the shoulder view of Integrated Third Person to half again as big, closer to the middle of the screen, and on the side away from the Helldiver.

## 1.17.0

- Added the stamina bar option, on by default: a thin white bar under the health bar of each player on this computer, emptying while sprinting and filling back up after. Players on other computers get none, as the game does not send stamina over the network.
- Changed the shield on the player health bars to cover the red over the full height of the bar, in place of the top half.
- Changed the player health bars to a fifth taller, keeping the bottom edge in place, with the health numbers a fifth bigger to match.
- Changed the reload and ammo circles in the shoulder view of Integrated Third Person to a fixed spot half way up the screen, out past the Helldiver on the side away from the camera shoulder. When the camera swaps shoulders, the spot eases across.
- Changed the enemy health bars in the shoulder view of Integrated Third Person to sit a little lower over each enemy.
- Changed the damage numbers on players in the shoulder view of Integrated Third Person to start above the name card over the head.
- Changed the enemy health bars in the shoulder view of Integrated Third Person to hide the bar of an enemy out of view until the enemy is looked at, as with Third Person Camera, in place of holding the bar at the edge of the screen.
- Changed the icon other mods can place on an enemy health bar to half again as big, so the mark reads at a glance.

## 1.16.1

- The icon of an `elite_mark` is half again as big, so it reads at a glance.
- With Integrated Third Person, a bar out of view is hidden instead of pinned to the edge, as with Third Person Camera.

## 1.16.0

- Added `elite_mark` for other mods: the health bar of a marked enemy shows from the start and stays while the enemy lives, with the icon the mod gives in the middle of the bar, white with the soft outline of the status icons.
- Fixed: With Third Person Camera on, the health bar of an enemy out of view no longer waits at the edge of the screen. It is hidden until the enemy is looked at.

## 1.15.1

- Fixed: With Third Person Camera on, the health bar of an enemy out of view no longer waits at the edge of the screen. It is hidden until the enemy is looked at.

## 1.15.0

- Changed the player health bars to about a third thinner, keeping the bottom edge in place.
- Added a fade to the player health bars: after 10 seconds at full health a bar turns grey at 50% opacity, and returns when health is lost or a shield drops below full.
- Changed the health numbers on the player bars to a smaller size to fit.
- Changed the shadow of damage numbers to half the distance from the number.
- Changed the shadow around the status icons over enemy health bars to less than half as dark.
- Fixed `status_effect` for other mods, which stopped with an error when given the seconds as text.
- Fixed a possible crash when the health bar of an enemy that was already gone looked up the enemy kind.

## 1.14.0

- Fixed the grenade counter and the grenade charge meter, which never showed: the size of the grenade icon was read in a way the game does not support.
- Changed status build-up on enemies to show as the status icon over the health bar, white, filling from the bottom in the color of the status, in place of the strip under the bar.
- Changed the status icons over enemy health bars to 10% smaller.
- Added `drain` and `icon` to `status_buildup` for other mods: the fill runs down to empty over that many seconds, for a build-up wearing off or an effect running out. A call without an icon still draws a strip under the bar, now thicker and on a dark track.
- Changed `status_effect` for other mods to show the icon full and running down over the effect.
- Fixed the ammo circle of an overheated laser, which showed a full ring: it now empties, flashes red and shows the reload button, as an empty magazine does.
- Changed the ammo circle to fade from yellow to red as the magazine runs from 30% to empty, in place of turning red at once.
- Changed the ammo circle of a laser to pulse between yellow and red from half heat, faster as it heats. An overheat flashes the ring white, shakes it, and pulses the track in a stronger red.
- Added a slight shake to the ammo circle when a magazine runs dry.
- Added a white flash to the ammo circle of an arc weapon when the charge is let go: the ring shakes, turns white and fades out.
- Changed the shadow on the reload and ammo circles to lighter.

## 1.13.0

- Added the grenade counter option, on by default: replaces the lower grenade icon on each player card with the number of grenades, such as x3, so counts above two show.
- Added `grenade_meter` for other mods: a charge meter on the upper grenade icon of a player card, filling from left to right.
- Added `flash_health` for other mods: the health bar of a player card flashes white and fades out.
- Added `status_buildup` for other mods: a thin strip along the bottom of an enemy health bar shows how far fire, poison or stun has built up, in the color of the status.
- Added `status_effect` for other mods: an icon over an enemy health bar while an effect runs, with a soft outline, fading in when the effect starts.

## 1.12.2

- Removed the black outline around the player health bars. The grey frame stays.

## 1.12.1

- Changed the health numbers to sit against the right end of each player health bar.
- Changed the enemy health bars back to the height they had before 1.9.0, with a black outline twice as thick.

## 1.12.0

- Added French, Spanish and Brazilian Portuguese to the Mods page of the pause menu, shown in the language set in the game. Needs Obsidian API 1.16.0 or later.
- Added Brazilian Portuguese and Chinese to the options in Obsidian.

## 1.11.0

- Removed the dividers that split the ammo circle into a segment for each round. The circle is one band again.

## 1.10.0

- Changed the ring of an arc weapon to fill in blue while the trigger is held, dim until the charge is enough to fire and bright from there.
- Fixed a full charge flashing the ring as empty.

## 1.9.0

- Changed the ammo circle to one yellow tone with a segment for each round, in groups of 5, 10, 25 and up past 30 rounds, and red below a tenth of the magazine. Lasers fill the ring counterclockwise with heat, red past nine tenths, and arc weapons are blue. A finished reload hides the ring until the next shot.
- Changed the ammo and reload circles to sit left of the Helldiver and a little higher, with a soft shadow from the bottom left.
- Changed the shadow of the player health bars to come from the left, and added a thin black outline around each bar.
- Changed the enemy health bars to twice as thick and slightly see-through, with one white stretch of lost health that each hit renews and that fades all at once after the last hit. Bars of enemies out of view wait at the edge of the screen.
- Changed the damage number shadow to 25% less opaque and a third closer.
- Changed the HUD to draw nothing while the photo mode effect of Obsidian API is on.
- Added a picture for the mod in Obsidian.

## 1.8.0

- Added an ammo circle beside each local Helldiver, with an option: a yellow ring filled with the share of the magazine or heat left. When empty, the track flashes between black and dark red, with the reload button in the middle for weapons that fire rounds. The ring fades out over a second after 8 seconds without a shot, and the reload circle takes the spot during a reload.
- Changed every setting to an option in Obsidian, tied to the row with the same id on the Mods page of the pause menu. Needs Obsidian API 1.16.0 or later. Values set in game before 1.8.0 move into the options once.
- Changed stacked damage numbers to start rising at once, fastest at the start. Added-up numbers stay in place, add every hit while they show and fade out where they stand.
- Changed damage numbers to white with a hard drop shadow, the text style of the stats in Helldivers Arcade.
- Added a soft shadow from left to right to the player health and shield bars.
- Changed the reload circle to sit a little further right.

## 1.7.1

- Changed the shield bar to the yellow the game uses for shields, in place of cyan.

## 1.7.0

- Added the shield to the player health bars, from the Shield Generator Pack or the shield upgrade in Helldivers Arcade, as a cyan bar over the top half.
- Changed the downed bar to a brighter crimson.
- Changed the reload circle to sit to the right of the Helldiver, clear of subtitles, in light grey on a lighter track. The circle grows and fades out in 0.1 seconds when a reload finishes, and the size follows the UI scale setting.
- Changed damage numbers to the HUD font, with a fainter outline and no drop shadow.
- Removed Off from the damage numbers mode: the Damage numbers option turns them off. A saved mode of Off moves to that option, so numbers that were off stay off.
- Changed the ammo counter to hide while a stratagem code is entered or a stratagem beacon is held.

## 1.6.1

- Fixed the reload circle, which followed only the first player. It now shows over every Helldiver played on this computer, local co-op players included, and not over bots.

## 1.6.0

- Added a reload circle: a ring over the Helldiver that fills while the weapon in hand reloads. On by default, with an option on the Mods page.
- Added a dark outline and a soft drop shadow to damage numbers, so they stay readable on snow, sand and explosions.

## 1.5.0

- Changed the ammo counter to show only for weapons that fire rounds: guns, flamethrowers and launchers. Lasers and arc weapons no longer get a counter.

## 1.4.0

- Added damage numbers that rise and fade where damage lands, stacked or added up, next to the target, above the health bar or at the hit.
- Changed the enemy bars to show for enemies the player hits and for heavies any player hurts, without ticks, with a burn, poison or stun as a pulsing outline, and with a white flash on death that fades twice as fast.
- Changed the player health bar to sit against the card.
- Changed the health numbers and the two Hide options to off by default.

## 1.3.0

- Added health numbers on the player bars: current and maximum health at the left of each bar, with a Mod Settings option.
- Changed the help lines of the settings to say plainly what each part does.

## 1.2.0

- Changed the ammo counter to cover every weapon: rounds for guns, flamethrowers and launchers, heat for lasers and charge for arc weapons.
- Added a red tint to laser heat near overheating.

## 1.1.0

- Added two Mod Settings options that hide the health bar and the get-up bar the game draws over each Helldiver, as the bars under the cards show the same. Both start hidden.
- Changed the enemy bars to a little thinner, with a light top and a dark bottom.

## 1.0.1

- Changed the README and the code to name no other mod. Nothing changes in game.

## 1.0.0

- Added an ammo counter.
- Added a health bar under each player card, with a lag behind health lost and a yellow get-up bar while downed. The bars show in missions only, and not while dead.
- Added health bars over damaged enemies, or over damaged heavies only, with a white lag behind losses, a tint for fire and poison, a pulsing backing while stunned, ticks every 100 health, a size by maximum health and a dark red flash on death.
- Added faction colors to the enemy bars: orange for Bugs, red for Cyborgs and purple for Illuminates. Enemy bars are twice as tall and follow the UI scale of the game.
- Added white chunks that fade out where health is lost, on enemy and player bars.
- Added a Mod Settings page with the options.
