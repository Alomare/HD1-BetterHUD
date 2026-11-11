-- The player health bars under the cards, the shield over them and the stamina bar (src/health.lua).
local health = obsidian.module("src/health")

-- Draws one card with stand-ins for the engine, and answers the rectangles drawn: { x, y, w, h, c }, y up
-- from the bottom of the card.
local function card(hs, cs, show, shield)
	local drawn = {}
	local V = function(x, y, z) return { x = x, y = y, z = z } end
	rawset(_G, "Vector3", V)
	rawset(_G, "Vector2", V)
	rawset(_G, "Color", function(a, r, g, b) return { a, r, g, b } end)
	rawset(_G, "LuaSettingsManager", { get_settings_by_unit = function() return { character_info = { sprint_stamina = 5 } } end })
	local gui = {
		rect = function(_, at, size, c) drawn[#drawn + 1] = { x = at.x, y = at.y, w = size.x, h = size.y, c = c } end,
		move = function() end,
	}
	local hud = {
		hd_gui = gui,
		hud_info = { [1] = { width = 248, state = "normal", shield_state = shield or {} } },
		get_player_hud_pos = function() return V(0, 0, 0) end,
	}
	local ok, err = pcall(health.draw_card, hud, 0.016, {}, 1, hs, cs, show)
	for _, k in ipairs({ "Vector3", "Vector2", "Color", "LuaSettingsManager" }) do rawset(_G, k, nil) end
	if not ok then error(err, 0) end
	return drawn
end

local function colored(drawn, c)
	local out = {}
	for _, r in ipairs(drawn) do
		if r.c[1] == c[1] and r.c[2] == c[2] and r.c[3] == c[3] and r.c[4] == c[4] then out[#out + 1] = r end
	end
	return out
end

local RED, RED_TOP = { 255, 255, 55, 25 }, { 255, 255, 130, 95 }
local SHIELD, SHIELD_TOP = { 255, 255, 190, 17 }, { 255, 255, 225, 120 }
local STAMINA = { 235, 255, 255, 255 }
local FULL = { hitpoints = 100, max_hitpoints = 100, constitution = -100 }

return {
	{ "the health bar is a fifth taller than in 1.16, grown upward from the same bottom edge", function()
		near(health.HEIGHT / 5.75, 1.2, "a fifth taller", 0.01)
		eq(health.BOTTOM, -9, "same bottom edge")
		local d = card(FULL, {}, { bars = true })
		local fill, top = colored(d, RED)[1], colored(d, RED_TOP)[1]
		near(fill.y, -9, "the fill starts at the bottom edge")
		near(top.y + top.h, -9 + health.HEIGHT, "and reaches the full height")
		eq(top.y + top.h + 1 <= 0, true, "the backing stays under the card")
	end },

	{ "a shield covers the red, the full height of the bar", function()
		local d = card({ hitpoints = 60, max_hitpoints = 100, constitution = -100 }, {}, { bars = true },
			{ shield_activated = true, shieldpoints = 5, max_shieldpoints = 10 })
		local fill, top = colored(d, SHIELD)[1], colored(d, SHIELD_TOP)[1]
		near(fill.y, -9, "from the bottom edge")
		near(top.y + top.h, -9 + health.HEIGHT, "to the top")
		near(fill.w, 250 * 0.5, "as long as the shield is full")
		near(colored(d, RED)[1].w, 250 * 0.6, "the health under it as before")
	end },

	{ "stamina: a thin white bar just under the health bar, for a player on this machine", function()
		local d = card(FULL, { sprint_stamina = 2.5 }, { bars = true, stamina = true })
		local s = colored(d, STAMINA)
		eq(#s, 1, "one stamina fill")
		near(s[1].w, 250 * 0.5, "half the stamina left")
		near(s[1].h, health.STAMINA_HEIGHT, "thin")
		eq(health.STAMINA_HEIGHT <= 2, true, "very thin")
		near(s[1].y + s[1].h, -9 - 1 - health.STAMINA_GAP, "just under the backing of the health bar")
		eq(#colored(card(FULL, { rotation_angle = 0 }, { bars = true, stamina = true }), STAMINA), 0,
			"a card of another machine has no stamina to show")
		eq(#colored(card(FULL, { sprint_stamina = 5 }, { bars = true }), STAMINA), 0, "the option off")
	end },

	{ "the stamina bar shows without the health bars, and not while downed", function()
		local d = card(FULL, { sprint_stamina = 5 }, { stamina = true })
		eq(#colored(d, RED), 0, "no health bar")
		eq(#colored(d, STAMINA), 1, "the stamina bar")
		near(colored(d, STAMINA)[1].w, 250, "full")
		d = card({ hitpoints = -20, max_hitpoints = 100, constitution = -100 }, { sprint_stamina = 5 }, { bars = true, stamina = true })
		eq(#colored(d, STAMINA), 0, "downed")
	end },

	{ "stamina share", function()
		eq(health.stamina_share(nil, 5), nil, "no reading")
		eq(health.stamina_share(2, 0), nil, "no most")
		near(health.stamina_share(2.5, 5), 0.5)
		eq(health.stamina_share(7, 5), 1, "no more than full")
		eq(health.stamina_share(-1, 5), 0)
	end },

	{ "the strips cover the bar: the shadow comes from the left and clears to the right", function()
		local strips = health.shade_strips(health.SHADE_STRIPS, health.SHADE_MAX)
		eq(#strips, health.SHADE_STRIPS, "strips")
		eq(strips[1].from, 0, "from the left end")
		near(strips[#strips].to, 1, "to the right end")
		for i = 2, #strips do
			near(strips[i].from, strips[i - 1].to, "no gap between strips")
			eq(strips[i].alpha < strips[i - 1].alpha, true, "lighter to the right")
		end
		eq(strips[#strips].alpha <= 5, true, "almost clear at the right")
		eq(strips[1].alpha <= health.SHADE_MAX, true, "no darker than the most")
		eq(strips[1].alpha >= health.SHADE_MAX - 5, true, "darkest at the left")
		eq(health.SHADE_MAX <= 96, true, "subtle")
	end },

	{ "shield fill", function()
		eq(health.shield_fill(nil), nil, "no shield")
		eq(health.shield_fill({ shield_activated = false, shieldpoints = 5, max_shieldpoints = 10 }), nil, "off")
		near(health.shield_fill({ shield_activated = true, shieldpoints = 5, max_shieldpoints = 10 }), 0.5, "half")
	end },

	{ "the bar fades only after 10 seconds of full health, and comes back when health is lost", function()
		local s = { full = 0, t = 0 }
		eq(health.step_idle(s, true, 9.9), 0, "not yet")
		near(health.step_idle(s, true, 0.1), 0.1, "starts at 10 seconds")
		eq(health.step_idle(s, true, 2), 1, "fully faded, and no further")
		eq(health.step_idle(s, false, health.FADE_IN), 0, "back when hurt")
		eq(s.full, 0, "the 10 seconds start over")
		eq(health.step_idle(s, true, 9.9), 0, "not yet, again")
	end },

	{ "faded colors are grey at half their alpha, and unfaded ones are untouched", function()
		local a, r, g, b = health.tint({ 255, 255, 55, 25 }, 1)
		eq(a, 128, "half opacity")
		eq(r, g, "grey")
		eq(g, b, "grey")
		a, r, g, b = health.tint({ 200, 8, 9, 10 }, 0)
		eq(a, 200) eq(r, 8) eq(g, 9) eq(b, 10)
	end },

	{ "a flash starts white and fades out over its length", function()
		eq(health.flash_alpha(2, 2), 255, "full at the start")
		eq(health.flash_alpha(1, 2) < 128, true, "past half gone by the middle")
		eq(health.flash_alpha(1, 2) > 0, true)
		eq(health.flash_alpha(0, 2), 0, "gone at the end")
		eq(health.flash(nil, 2), false)
		eq(health.flash({}, 2), true)
	end },
}
