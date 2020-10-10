local function dye_to_color(name)
	if not unifieddyes or not unifieddyes.get_color_from_dye_name then
		return "#ffffff"
	end
	return "#"..unifieddyes.get_color_from_dye_name(name)
end

--[[
	def = {
		type = "shoes" | "trousers" | "shirt" | "sweater" | "belt" | "jacket" | "cape" | "hat" | "glove" | "face_accessory", -- Used for correct layering
		description = "", -- Description of the item
		skin = "", -- Texture for the skin; must be 64x32px
		inventory_image = "", -- Inventory image for the item
		colorable = false, -- Optional; allows meta-based coloring; requires unifieddyes
		default_color = ColorString, -- Optional; defines the initial color.
		recipe = {
			{"", "", ""},
			{"", "", ""},
			{"", "", ""},
		}, -- Optional; recipe for the item
	}
]]
function ts_skins.register_clothing(name, def)
	minetest.register_craftitem(":ts_skins:clothing_"..name, {
		description = def.description,
		inventory_image = def.inventory_image,
		_ts_skins = {
			type = def.type,
			skin = def.skin,
			colorable = def.colorable
		},
	})
	if def.recipe then
		local item = "ts_skins:clothing_"..name
		local output = def.default_color and minetest.itemstring_with_color(item, def.default_color) or item
		minetest.register_craft({
			output = output,
			recipe = def.recipe
		})
	end
	if def.colorable and unifieddyes and unifieddyes.get_color_from_dye_name then
		minetest.register_craft({
			output = "ts_skins:clothing_"..name,
			type = "shapeless",
			recipe = { "ts_skins:clothing_"..name, "group:dye" }
		})
	end
end

if unifieddyes then
	local craft_function = function(itemstack, player, old_craft_grid, craft_inv)
		local clothing, dye
		for _,stack in ipairs(old_craft_grid) do
			local def = stack:get_definition()
			if def._ts_skins and def._ts_skins.colorable then
				if clothing then
					return nil
				else
					clothing = stack
				end
			elseif def.groups and def.groups.dye then
				if dye then
					return nil
				else
					dye = stack
				end
			elseif stack:get_name() ~= "" then
				return nil
			end
		end
		if not clothing or not dye then
			return nil
		end

		local meta = itemstack:get_meta()
		meta:set_string("color", dye_to_color(dye:get_name()))
		return itemstack
	end

	minetest.register_on_craft(craft_function)
	minetest.register_craft_predict(craft_function)
end



ts_skins.register_clothing("pullover", {
	type = "shirt", -- Should be below trousers
	description = "Pullover",
	skin = "ts_skins_pullover.png",
	inventory_image = "ts_skins_pullover_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:green"),
	recipe = {
		{ "wool:green", "", "wool:green" },
		{ "wool:green", "wool:green", "wool:green" },
		{ "wool:green", "wool:green", "wool:green" },
	}
})

ts_skins.register_clothing("trousers", {
	type = "trousers", -- Should be below trousers
	description = "Trousers",
	skin = "ts_skins_trousers.png",
	inventory_image = "ts_skins_trousers_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:black"),
	recipe = {
		{ "wool:black", "wool:black", "wool:black" },
		{ "wool:black", "", "wool:black" },
		{ "wool:black", "", "wool:black" },
	}
})

ts_skins.register_clothing("shoes", {
	type = "shoes", -- Should be below trousers
	description = "Shoes",
	skin = "ts_skins_shoes.png",
	inventory_image = "ts_skins_shoes_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:black"),
	recipe = {
		{ "wool:black", "", "wool:black" },
		{ "wool:black", "", "wool:black" },
	}
})