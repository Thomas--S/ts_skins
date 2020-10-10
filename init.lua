ts_skins = {}
ts_skins.storage = minetest.get_mod_storage()

function string.starts_with(s, start)
	return string.sub(s, 1, string.len(start)) == start
end


local modpath = minetest.get_modpath("ts_skins")

dofile(modpath.."/base.lua")
dofile(modpath.."/clothing.lua")
dofile(modpath.."/palettes.lua")
dofile(modpath.."/unified_inventory.lua")
dofile(modpath.."/3d_armor.lua")