-- The shadow over the player health and shield bars (src/health.lua).
local health = obsidian.module("src/health")

return {
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
