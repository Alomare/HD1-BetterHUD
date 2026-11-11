-- A health bar under the card of each player, as wide as the card, in missions: red for health, white
-- chunks that fade out where health was lost, as the bars of the game do, a yellow shield bar over the
-- red, the full height of the bar, while a shield holds, crimson while downed and bleeding out, and none
-- while dead. The health and shield fills get a soft shadow that is darkest at the left and clears toward
-- the right. While downed, a yellow bar half as tall shows how far getting back up has come. The hitpoints
-- of remote players are replicated, so every card has a health bar.
--
-- Under the health bar, a thin white stamina bar for each player on this machine (M.stamina_share). The
-- game keeps sprint_stamina, the seconds of full-speed sprint left, only in the master state of the
-- character: the value fills by 1 a second up to character_info.sprint_stamina (5 for a Helldiver) while not
-- sprinting (character_component.lua:564), drains by 1 a second while sprinting
-- (CharacterSubstateSprint.update_sprint), and slows the sprint from move_speed_sprint_max to
-- move_speed_sprint_min as it runs out. The character fields sent to other machines
-- (network_object_settings.lua) leave it out, and the cards of remote players get the slave state
-- (Hud.update_and_draw_hud), so only the cards of this machine show stamina.
--
-- The cards sit along the bottom of the screen in the HUD's 1280x720 space, y up, each growing upward
-- from y = 0 at Hud:get_player_hud_pos(slot) (hud.lua:1412), 54 design units over the bottom edge
-- (hud_settings_default.lua margin). The space just under a card is empty.
local api = obsidian.import("obsidian.api")

local M = {}

local function g(name) return rawget(_G, name) end

-- The bottom edge of the bar under the card, and the height: 5.75 before 1.17.0, then a fifth taller, upward.
M.BOTTOM, M.HEIGHT = -9, 6.9
local HEIGHT, BOTTOM = M.HEIGHT, M.BOTTOM
local Z = 20
local CHUNK_LIFE, CHUNKS = 1, 5 -- a lost stretch fades out in this many seconds; this many at once

local bars = {}

local function clamp(x) return math.max(0, math.min(1, x)) end

-- Each loss leaves a white chunk where the health was, fading out, as the game's own bars do
-- (hud.lua:461-476). A heal drops the chunks it covers.
local function chunks_of(slot, pct, dt)
	local b = bars[slot]
	if not b then
		b = { pct = pct, chunks = {} }
		bars[slot] = b
	end
	if pct < b.pct - 1e-4 then
		table.insert(b.chunks, { from = pct, to = b.pct, life = CHUNK_LIFE })
		if #b.chunks > CHUNKS then table.remove(b.chunks, 1) end
	end
	for i = #b.chunks, 1, -1 do
		local c = b.chunks[i]
		c.life = c.life - dt
		if c.life <= 0 or pct >= c.to then table.remove(b.chunks, i) else c.from = math.max(c.from, pct) end
	end
	b.pct = pct
	return b.chunks
end

local DEAD_STATES = { dead = true, countdown = true, wait_for_spawn = true }

-- In the look of the card above: a dark backing, a darker track inset in it, the game's own health
-- red (hud_settings.lua) with a lighter top edge.
local BACK, TRACK = { 170, 22, 24, 26 }, { 200, 8, 9, 10 }
local RED, RED_TOP = { 255, 255, 55, 25 }, { 255, 255, 130, 95 }
local LAG, DOWNED = { 255, 255, 255 }, { 255, 220, 40, 34 }
local YELLOW, YELLOW_TOP = { 255, 255, 190, 17 }, { 255, 255, 225, 120 }
-- Shield: a yellow bar over the red, the full height of the health bar, as long as the shield is full, in
-- the color the game gives shields on the health bars it draws (hud_settings.lua foreground_shield).
local SHIELD, SHIELD_TOP = { 255, 255, 190, 17 }, { 255, 255, 225, 120 }
-- Stamina: STAMINA_HEIGHT design units tall, STAMINA_GAP under the dark backing of the health bar.
M.STAMINA_HEIGHT, M.STAMINA_GAP = 1.5, 1
local STAMINA, STAMINA_TRACK = { 235, 255, 255, 255 }, { 150, 8, 9, 10 }

-- How full the shield is, from 0 to 1, or nil for none. The Shield Generator Pack sets the shield's
-- points and maximum with set_shield_info (shield_component.lua), and Helldivers Arcade's shield
-- upgrade adds to the same command, so one state covers both. The game's own bar shows it only while
-- shield_activated (Hud.draw_health_bar).
function M.shield_fill(ss)
	if type(ss) ~= "table" or not ss.shield_activated then return nil end
	local points = tonumber(ss.shieldpoints) or 0
	local max = tonumber(ss.max_shieldpoints) or (type(ss.shield_info) == "table" and tonumber(ss.shield_info.shield)) or 0
	if points <= 0 or max <= 0 then return nil end
	return clamp(points / max)
end

-- After this many seconds at full health the bar fades to grey and half opacity; losing health brings it back.
M.IDLE_AFTER, M.FADE_OUT, M.FADE_IN, M.FADED_OPACITY = 10, 1, 0.2, 0.5
local FULL = 1 - 1e-4

-- Advances s = { full = seconds full so far, t = how faded, 0 to 1 } by dt, and returns t.
function M.step_idle(s, full, dt)
	if full then
		s.full = s.full + dt
		if s.full >= M.IDLE_AFTER then s.t = math.min(1, s.t + dt / M.FADE_OUT) end
	else
		s.full = 0
		s.t = math.max(0, s.t - dt / M.FADE_IN)
	end
	return s.t
end

-- A color { a, r, g, b } at fade t, as the four numbers: toward the color's own grey and half the alpha.
function M.tint(c, t)
	if t <= 0 then return c[1], c[2], c[3], c[4] end
	local grey = 0.299 * c[2] + 0.587 * c[3] + 0.114 * c[4]
	local function toward_grey(v) return math.floor(v + (grey - v) * t + 0.5) end
	return math.floor(c[1] * (1 - (1 - M.FADED_OPACITY) * t) + 0.5), toward_grey(c[2]), toward_grey(c[3]), toward_grey(c[4])
end

local idle = {} -- slot -> the state for M.step_idle
local fade = 0 -- how faded the bar being drawn is

local function rect(gui, x, y, z, w, h, c)
	if w <= 0 then return end
	gui:rect(g("Vector3")(x, y, z), g("Vector2")(w, h), g("Color")(M.tint(c, fade)))
end

-- A soft shadow over a fill, coming from the left: darkest at the left end of the bar, clear at the right
-- end, in strips of black that get less opaque. Each strip: { from, to } as shares of the bar's width,
-- and the black's alpha.
M.SHADE_STRIPS, M.SHADE_MAX = 16, 72

function M.shade_strips(n, max)
	local out = {}
	for i = 1, n do
		out[i] = { from = (i - 1) / n, to = i / n, alpha = math.floor(max * (n - i + 0.5) / n + 0.5) }
	end
	return out
end

local SHADE = M.shade_strips(M.SHADE_STRIPS, M.SHADE_MAX)

-- The shadow over the part of a bar `w` wide that a fill of `pct` covers.
local function shade(gui, x, y, z, w, h, pct)
	for _, s in ipairs(SHADE) do
		if s.from >= pct then break end
		rect(gui, x + w * s.from, y, z, w * (math.min(s.to, pct) - s.from), h, { s.alpha, 0, 0, 0 })
	end
end

-- Health and the most it can be, inside the bar against the right end, in white over a shadow.
local TEXT_SIZE = 7.7 -- design units, about the height of the bar (6.4 before the bar grew in 1.17.0)
local TEXT_X, TEXT_Y = 4, 1.1 -- from the bottom right of the bar to the end of the words, and to the baseline
local INK, SHADOW = { 255, 255, 255, 255 }, { 210, 0, 0, 0 }

local function numbers(gui, right, y, hp, max)
	local text = string.format("%d / %d", math.ceil(hp), math.floor(max + 0.5))
	local V3, C = g("Vector3"), g("Color")
	gui:set_current_font("body_large")
	-- The extents come in pixels, as in src/ammo.lua.
	local ok, width = pcall(gui.get_text_extents, gui, text, nil, TEXT_SIZE)
	local x = right - TEXT_X - ((ok and tonumber(width) or 0) / (tonumber(gui.ui_scale) or 1))
	gui:text(text, V3(x + 0.6, y + TEXT_Y - 0.6, Z + 9), C(M.tint(SHADOW, fade)), nil, TEXT_SIZE)
	gui:text(text, V3(x, y + TEXT_Y, Z + 10), C(M.tint(INK, fade)), nil, TEXT_SIZE)
end

-- A bar at x, y (its bottom left): backing, track, then a fill of `pct` with a lighter top edge, and with
-- `shaded`, the shadow over the fill. While it fades the layers don't overlap, or their half opacities
-- would stack into a nearly solid bar: the backing is only an outline and the track only the unfilled part.
local function bar(gui, x, y, w, h, pct, fill, top, shaded)
	if fade > 0 then
		rect(gui, x - 1, y - 1, Z, w + 2, 1, BACK)
		rect(gui, x - 1, y + h, Z, w + 2, 1, BACK)
		rect(gui, x - 1, y, Z, 1, h, BACK)
		rect(gui, x + w, y, Z, 1, h, BACK)
		rect(gui, x + w * pct, y, Z + 1, w * (1 - pct), h, TRACK)
	else
		rect(gui, x - 1, y - 1, Z, w + 2, h + 2, BACK)
		rect(gui, x, y, Z + 1, w, h, TRACK)
	end
	rect(gui, x, y, Z + 3, w * pct, top and h - 1 or h, fill)
	if top then rect(gui, x, y + h - 1, Z + 4, w * pct, 1, top) end
	if shaded then shade(gui, x, y, Z + 5, w, h, pct) end
end

-- The card keeps the player's shield state (Hud.update_and_draw_hud); a unit without one has none.
local function shield_state(info, unit)
	if info.shield_state then return info.shield_state end
	local aux = g("EntityAux")
	if not aux.has_component(unit, "shield") then return nil end
	return aux.state(unit, "shield")
end

-- How full the stamina is, from 0 to 1, or nil without a stamina reading (a player on another machine).
function M.stamina_share(stamina, max)
	if type(stamina) ~= "number" or type(max) ~= "number" or max <= 0 then return nil end
	return clamp(stamina / max)
end

local stamina_max = setmetatable({}, { __mode = "k" }) -- unit -> character_info.sprint_stamina

-- The most stamina the unit holds: the character settings of the unit, read once, else the value the
-- last sprint started from, else the 5 of a Helldiver.
local function max_stamina(unit, st)
	local m = stamina_max[unit]
	if m then return m end
	local lsm = g("LuaSettingsManager")
	if lsm then
		local ok, settings = pcall(lsm.get_settings_by_unit, lsm, unit)
		local info = ok and type(settings) == "table" and settings.character_info
		m = type(info) == "table" and tonumber(info.sprint_stamina) or nil
	end
	m = m or tonumber(st.initial_sprint_stamina) or 5
	stamina_max[unit] = m
	return m
end

-- The stamina and the most there can be, or nil. The card of a player on this machine holds the master
-- state; anything else asks Obsidian API for one.
function M.stamina_of(cs, unit)
	local st = cs
	if not (type(st) == "table" and type(st.sprint_stamina) == "number") then
		local game = type(api) == "table" and api.game
		local ok, master = pcall(type(game) == "table" and game.master, unit, "character")
		st = ok and master or nil
	end
	if not (type(st) == "table" and type(st.sprint_stamina) == "number") then return nil end
	return st.sprint_stamina, max_stamina(unit, st)
end

local stamina_idle = {} -- slot -> the state for M.step_idle, for the stamina bar

-- The stamina bar under a health bar at x, y (the bottom left of the health bar), w wide. Full for
-- IDLE_AFTER seconds, it fades as the health bar does.
local function draw_stamina(gui, x, y, w, share, slot, dt)
	stamina_idle[slot] = stamina_idle[slot] or { full = 0, t = 0 }
	fade = M.step_idle(stamina_idle[slot], share >= FULL, dt or 0)
	local h = M.STAMINA_HEIGHT
	-- The backing of the health bar reaches 1 design unit under the bar.
	local bottom = y - 1 - M.STAMINA_GAP - h
	-- Faded, the track shows only where the fill doesn't, so the two half opacities don't stack.
	if fade > 0 then
		rect(gui, x + w * share, bottom, Z, w * (1 - share), h, STAMINA_TRACK)
	else
		rect(gui, x, bottom, Z, w, h, STAMINA_TRACK)
	end
	rect(gui, x, bottom, Z + 1, w * share, h, STAMINA)
end

-- Flashes another mod asks for (M.flash): unit -> { left, total }. The bar shows white over everything,
-- fading out, with a glow a little past its edges.
local flashes = {}
local FLASH_GLOW = 2 -- design units past the bar's edges

-- The white's alpha `left` seconds from the end of a flash `total` long: full at the start, fading out,
-- quickly at first.
function M.flash_alpha(left, total)
	if not (total and total > 0 and left and left > 0) then return 0 end
	return math.floor(255 * clamp(left / total) ^ 1.5 + 0.5)
end

-- obsidian.import("alomare.betterhud").flash_health(unit, seconds): the health bar of the player whose
-- avatar is `unit` flashes white, fading out over `seconds` (2 when left out). A new flash starts over.
function M.flash(unit, seconds)
	if unit == nil then return false end
	seconds = tonumber(seconds) or 2
	if seconds <= 0 then flashes[unit] = nil return true end
	flashes[unit] = { left = math.min(seconds, 10), total = math.min(seconds, 10) }
	return true
end

local function draw_flash(gui, unit, x, y, w, dt)
	local f = flashes[unit]
	if not f then return end
	local alpha = M.flash_alpha(f.left, f.total)
	f.left = f.left - (dt or 0)
	if f.left <= 0 then flashes[unit] = nil end
	if alpha <= 0 then return end
	rect(gui, x - FLASH_GLOW, y - FLASH_GLOW, Z + 11, w + 2 * FLASH_GLOW, HEIGHT + 2 * FLASH_GLOW, { math.floor(alpha * 0.45), 255, 255, 255 })
	rect(gui, x, y, Z + 12, w, HEIGHT, { alpha, 255, 255, 255 })
end

-- One card. show: { bars = the health bars, numbers = health as numbers too, stamina = the stamina bar }.
local function draw(hud, dt, unit, slot, hs, cs, show)
	local info = hud.hud_info and hud.hud_info[slot]
	local gui = hud.hd_gui
	if not (info and gui) or hud.hidden or hud.enabled == false then return end
	-- A dead player has no bar.
	if not unit or not hs or hs.is_dead or DEAD_STATES[info.state] then
		bars[slot] = nil
		idle[slot] = nil
		stamina_idle[slot] = nil
		return
	end
	local w = (info.width or 248) + 2
	local x, y = -1, BOTTOM
	gui:move(hud:get_player_hud_pos(slot))
	do
		local max = hs.max_hitpoints or 100
		local hp = hs.hitpoints or max
		if hp > 0 then
			if show.bars then
				local pct = clamp(hp / max)
				local ok, ss = pcall(shield_state, info, unit)
				local fill = ok and M.shield_fill(ss)
				idle[slot] = idle[slot] or { full = 0, t = 0 }
				-- A shield taking damage is still news, so the bar stays awake until the shield is full or gone.
				fade = M.step_idle(idle[slot], pct >= FULL and not (fill and fill < FULL), dt or 0)
				bar(gui, x, y, w, HEIGHT, pct, RED, RED_TOP, true)
				for _, c in ipairs(chunks_of(slot, pct, dt or 0)) do
					rect(gui, x + w * c.from, y, Z + 2, w * (c.to - c.from), HEIGHT, { math.floor(230 * c.life / CHUNK_LIFE), LAG[1], LAG[2], LAG[3] })
				end
				if fill then
					-- Over the red, the full height of the bar.
					rect(gui, x, y, Z + 6, w * fill, HEIGHT - 1, SHIELD)
					rect(gui, x, y + HEIGHT - 1, Z + 7, w * fill, 1, SHIELD_TOP)
					shade(gui, x, y, Z + 8, w, HEIGHT, fill)
				end
				if show.numbers then numbers(gui, x + w, y, hp, max) end
			end
			local share = show.stamina and M.stamina_share(M.stamina_of(cs, unit))
			if share then draw_stamina(gui, x, y, w, share, slot, dt) else stamina_idle[slot] = nil end
		else
			-- Downed: what's left of the bleed-out pool, constitution being negative, and below it how
			-- far getting up has come. No sprint while downed, so no stamina bar.
			bars[slot] = nil
			idle[slot] = nil
			stamina_idle[slot] = nil
			fade = 0
			if show.bars then
				local pool = -(hs.constitution or -100)
				bar(gui, x, y, w, HEIGHT, pool > 0 and clamp((hp + pool) / pool) or 0, DOWNED, nil, true)
				local need = cs and tonumber(cs.get_up_presses_needed)
				if need and need > 0 then
					local h = HEIGHT / 2
					bar(gui, x, y - h, w, h, clamp((tonumber(cs.get_up_presses) or 0) / need), YELLOW, YELLOW_TOP)
				end
			end
		end
		fade = 0 -- a flash asked for by another mod shows at full strength
		if show.bars then draw_flash(gui, unit, x, y, w, dt) end
	end
	gui:move(g("Vector3")(0, 0, 0))
end
M.draw_card = draw

-- active(): whether the health bars show; numbers_on(): whether they show health as numbers too;
-- stamina_on(): whether the stamina bar shows, with the health bars or without.
function M.install(active, numbers_on, stamina_on)
	local failed = false
	local show = {}
	obsidian.hook("Hud", "draw_hud", function(original, self, dt, unit, name, slot, screen_pos, health_state, inventory_state, character_state, ...)
		local r = { original(self, dt, unit, name, slot, screen_pos, health_state, inventory_state, character_state, ...) }
		show.bars = active() == true
		show.numbers = numbers_on ~= nil and numbers_on() == true
		show.stamina = stamina_on ~= nil and stamina_on() == true
		-- The ship's HUD has cards too, with no health to show.
		if (show.bars or show.stamina) and api.game.in_mission() then
			local ok, err = pcall(draw, self, dt, unit, slot, health_state, character_state, show)
			if not ok and not failed then
				failed = true
				obsidian.log("betterhud: health bar: " .. tostring(err))
			end
		end
		return unpack(r)
	end)
end

return M
