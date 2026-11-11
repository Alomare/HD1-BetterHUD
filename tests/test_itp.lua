-- How Better HUD reads Integrated Third Person (src/itp.lua).
local itp = obsidian.module("src/itp")

return {
	{ "not installed: the top-down view, over the right shoulder", function()
		with_itp(nil, function()
			eq(itp.active(), false, "no mod")
			eq(itp.shoulder(), 1, "right")
		end)
		with_itp({}, function()
			eq(itp.active(), false, "no active()")
		end)
	end },

	{ "the shoulder view and the shoulder the camera sits over", function()
		local on, side = true, -1
		local mod = { active = function() return on end, shoulder = function() return side end }
		with_itp(mod, function()
			eq(itp.active(), true, "shoulder view")
			eq(itp.shoulder(), -1, "left")
			side = 1
			eq(itp.shoulder(), 1, "right")
			side = nil
			eq(itp.shoulder(), 1, "top-down answers nil: right")
			on = false
			eq(itp.active(), false, "toggled off")
		end)
	end },

	{ "a version before 0.2.0 has no shoulder(): the camera is over the right shoulder", function()
		with_itp({ active = function() return true end }, function()
			eq(itp.active(), true)
			eq(itp.shoulder(), 1)
		end)
	end },

	{ "an error in the mod counts as the top-down view", function()
		with_itp({ active = function() error("broken") end, shoulder = function() error("broken") end }, function()
			eq(itp.active(), false)
			eq(itp.shoulder(), 1)
		end)
	end },
}
