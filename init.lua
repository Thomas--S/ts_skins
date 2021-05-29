ts_skins = {}
ts_skins.storage = minetest.get_mod_storage()

if not armor.update_skin then
	error("armor.update_skin not found! If your version of 3d_armor doesn't provide this function, install the ts_skins_armor_integration mod. (https://github.com/Thomas--S/ts_skins_armor_integration)")
end

function string.starts_with(s, start)
	return string.sub(s, 1, string.len(start)) == start
end


local modpath = minetest.get_modpath("ts_skins")

dofile(modpath.."/base.lua")
dofile(modpath.."/clothing.lua")
dofile(modpath.."/palettes.lua")
dofile(modpath.."/unified_inventory.lua")
dofile(modpath.."/3d_armor.lua")
dofile(modpath.."/wardrobe.lua")