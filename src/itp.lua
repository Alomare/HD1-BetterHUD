-- Eyes of Liberty (alomare.eyesofliberty; before that Unleashed Camera, alomare.unleashedcamera, and before
-- 0.8.0 Integrated Third Person, alomare.integratedthirdperson), the camera mod, as Better HUD
-- reads it: whether the shoulder view steers the camera, and over which shoulder the camera sits. Looked up
-- once, on first use, through obsidian.import; a missing mod, or one without active(), counts as not
-- installed. shoulder() came with version 0.2.0: 1 with the camera over the right shoulder,
-- -1 over the left, nil in the top-down view. An older version has no shoulder(), and the camera there sits
-- over the right shoulder.
local M = {}

local mod -- nil: not looked up yet; false: not installed

local function get()
	if mod == nil then
		mod = false
		for _, id in ipairs({ "alomare.eyesofliberty", "alomare.unleashedcamera", "alomare.integratedthirdperson" }) do
			local ok, found = pcall(function() return obsidian.import and obsidian.import(id) end)
			if ok and type(found) == "table" and type(found.active) == "function" then
				mod = found
				break
			end
		end
	end
	return mod or nil
end

-- Whether the shoulder view steers the camera now.
function M.active()
	local m = get()
	if not m then return false end
	local ok, on = pcall(m.active)
	return ok and on == true
end

-- 1 with the camera over the right shoulder, -1 over the left. The side the camera is moving to while a
-- swap eases across.
function M.shoulder()
	local m = get()
	if not (m and type(m.shoulder) == "function") then return 1 end
	local ok, side = pcall(m.shoulder)
	if ok and side == -1 then return -1 end
	return 1
end

-- Looks the mod up again on next use, for the tests.
function M.reset()
	mod = nil
end

return M
