local function dye_to_color(name)
	if not unifieddyes or not unifieddyes.get_color_from_dye_name then
		return "#ffffff"
	end
	if name == "dye:brown" then
		return "#b43500"
	elseif name == "dye:pink" then
		return "#ff5050"
	end
	return "#"..unifieddyes.get_color_from_dye_name(name)
end

--[[
	def = {
		type = "shoes" | "trousers" | "shirt" | "sweater" | "tie" | "toga" | "coat" | "belt" | "jacket" | "cape" | "hat" | "glove" | "face_accessory", -- Used for correct layering
		description = "", -- Description of the item
		skin = "", -- Texture for the skin; must be 64x32px
		inventory_image = "", -- Inventory image for the item
		skin_overlay = "", -- Optional overlay texture for the skin; must be 64x32px; doesn't get colored
		inventory_overlay = "", -- Optional overlay image for the inventory; doesn't get colored
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
		inventory_overlay = def.inventory_overlay,
		_ts_skins = {
			type = def.type,
			skin = def.skin,
			colorable = def.colorable,
			skin_overlay = def.skin_overlay,
		},
		color = def.default_color,
		stack_max = 1,
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
		meta:set_string("description", clothing:get_definition().description.." ("..dye:get_description():gsub(" Dye", "")..")")
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

ts_skins.register_clothing("tanktop", {
	type = "shirt", -- Should be below trousers
	description = "Tank Top",
	skin = "ts_skins_tanktop.png",
	inventory_image = "ts_skins_tanktop_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:white"),
	recipe = {
		{ "farming:string", "farming:string" },
		{ "wool:white", "wool:white" },
		{ "wool:white", "wool:white" },
	}
})

ts_skins.register_clothing("trousers", {
	type = "trousers",
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

ts_skins.register_clothing("shorts", {
	type = "trousers",
	description = "Shorts",
	skin = "ts_skins_shorts.png",
	inventory_image = "ts_skins_shorts_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:blue"),
	recipe = {
		{ "wool:blue", "wool:blue", "wool:blue" },
		{ "wool:blue", "", "wool:blue" },
	}
})

ts_skins.register_clothing("shoes", {
	type = "shoes",
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

ts_skins.register_clothing("boots", {
	type = "shoes",
	description = "Boots",
	skin = "ts_skins_boots.png",
	inventory_image = "ts_skins_boots_inv.png",
	recipe = {
		{ "wool:black" },
		{ "ts_skins:clothing_shoes" },
	}
})

ts_skins.register_clothing("sneakers", {
	type = "shoes",
	description = "Sneakers",
	skin = "ts_skins_sneakers.png",
	skin_overlay = "ts_skins_sneakers_overlay.png",
	inventory_image = "ts_skins_sneakers_inv.png",
	inventory_overlay = "ts_skins_sneakers_inv_overlay.png",
	colorable = true,
	default_color = dye_to_color("dye:red"),
	recipe = {
		{ "wool:red", "", "wool:red" },
		{ "wool:white", "", "wool:white" },
	}
})

ts_skins.register_clothing("flat_shoes", {
	type = "shoes",
	description = "Flat Shoes",
	skin = "ts_skins_flat_shoes.png",
	inventory_image = "ts_skins_flat_shoes_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:white"),
	recipe = {
		{ "wool:white", "", "wool:white" },
	}
})

ts_skins.register_clothing("belt", {
	type = "belt",
	description = "Belt",
	skin = "ts_skins_belt.png",
	skin_overlay = "ts_skins_belt_overlay.png",
	inventory_image = "ts_skins_belt_inv.png",
	inventory_overlay = "ts_skins_belt_inv_overlay.png",
	colorable = true,
	default_color = dye_to_color("dye:black"),
	recipe = {
		{ "farming:string", "default:gold_ingot", "farming:string" },
	}
})

ts_skins.register_clothing("trousers_camo", {
	type = "trousers",
	description = "Trousers (Camouflage)",
	skin = "ts_skins_trousers_camo.png",
	inventory_image = "ts_skins_trousers_camo_inv.png",
	recipe = {
		{ "wool:black", "wool:dark_green", "wool:green" },
		{ "wool:dark_green", "", "wool:dark_green" },
		{ "wool:dark_green", "", "wool:brown" },
	}
})

ts_skins.register_clothing("shirt_camo", {
	type = "sweater", -- Should be above trousers
	description = "Shirt (Camouflage)",
	skin = "ts_skins_shirt_camo.png",
	inventory_image = "ts_skins_shirt_camo_inv.png",
	recipe = {
		{ "wool:dark_green", "", "wool:dark_green" },
		{ "wool:dark_green", "wool:black", "wool:dark_green" },
		{ "wool:green", "wool:dark_green", "wool:brown" },
	}
})

ts_skins.register_clothing("cap_camo", {
	type = "hat",
	description = "Cap (Camouflage)",
	skin = "ts_skins_cap_camo.png",
	inventory_image = "ts_skins_cap_camo_inv.png",
	recipe = {
		{ "wool:green", "wool:dark_green", "wool:brown" },
	}
})

ts_skins.register_clothing("hoodie", {
	type = "hat", -- The hood should cover the hair
	description = "Hoodie",
	skin = "ts_skins_hoodie.png",
	skin_overlay = "ts_skins_hoodie_overlay.png",
	inventory_image = "ts_skins_hoodie_inv.png",
	inventory_overlay = "ts_skins_hoodie_inv_overlay.png",
	colorable = true,
	default_color = dye_to_color("dye:red"),
	recipe = {
		{ "wool:red", "", "wool:red" },
		{ "wool:red", "farming:string", "wool:red" },
		{ "wool:red", "wool:red", "wool:red" },
	}
})

ts_skins.register_clothing("sunglasses", {
	type = "face_accessory",
	description = "Sunglasses",
	skin = "ts_skins_sunglasses.png",
	inventory_image = "ts_skins_sunglasses_inv.png",
	recipe = {
		{ "dye:black", "", "dye:black" },
		{ "default:obsidian_glass", "default:steel_ingot", "default:obsidian_glass" },
	}
})

ts_skins.register_clothing("face_mask", {
	type = "face_accessory",
	description = "Face Mask",
	skin = "ts_skins_face_mask.png",
	inventory_image = "ts_skins_face_mask_inv.png",
	recipe = {
		{ "farming:string", "wool:cyan", "farming:string" },
	}
})

ts_skins.register_clothing("tie", {
	type = "tie",
	description = "Tie",
	skin = "ts_skins_tie.png",
	inventory_image = "ts_skins_tie_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:red"),
	recipe = {
		{ "wool:red" },
		{ "wool:red" },
		{ "wool:red" },
	}
})

ts_skins.register_clothing("shirt", {
	type = "shirt",
	description = "Shirt",
	skin = "ts_skins_shirt.png",
	inventory_image = "ts_skins_shirt_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:white"),
	recipe = {
		{ "farming:string", "farming:string", "farming:string" },
		{ "farming:string", "farming:string", "farming:string" },
		{ "", "farming:string", "" },
	}
})

ts_skins.register_clothing("tshirt", {
	type = "shirt",
	description = "T-Shirt",
	skin = "ts_skins_tshirt.png",
	inventory_image = "ts_skins_tshirt_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:white"),
	recipe = {
		{ "farming:string", "", "farming:string" },
		{ "farming:string", "farming:string", "farming:string" },
		{ "farming:string", "farming:string", "farming:string" },
	}
})

ts_skins.register_clothing("jacket_open", {
	type = "jacket",
	description = "Jacket (Open)",
	skin = "ts_skins_jacket_open.png",
	inventory_image = "ts_skins_jacket_open_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:dark_grey"),
	recipe = {
		{ "wool:dark_grey", "", "wool:dark_grey" },
		{ "wool:dark_grey", "", "wool:dark_grey" },
		{ "wool:dark_grey", "", "wool:dark_grey" },
	}
})

ts_skins.register_clothing("jacket_closed", {
	type = "jacket",
	description = "Jacket (Closed)",
	skin = "ts_skins_jacket_closed.png",
	inventory_image = "ts_skins_jacket_closed_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:dark_grey"),
	recipe = {
		{ "wool:dark_grey", "", "wool:dark_grey" },
		{ "wool:dark_grey", "", "wool:dark_grey" },
		{ "wool:dark_grey", "wool:dark_grey", "wool:dark_grey" },
	}
})

ts_skins.register_clothing("safety_vest", {
	type = "cape", -- Should be above most other clothing
	description = "Safety Vest",
	skin = "ts_skins_safety_vest.png",
	inventory_image = "ts_skins_safety_vest_inv.png",
	recipe = {
		{ "wool:yellow", "", "wool:yellow" },
		{ "wool:white", "", "wool:white" },
		{ "wool:yellow", "wool:yellow", "wool:yellow" },
	}
})

ts_skins.register_clothing("jacket_high_viz", {
	type = "jacket",
	description = "High-visibility Jacket",
	skin = "ts_skins_jacket.png",
	skin_overlay = "ts_skins_jacket_high_viz_overlay.png",
	inventory_image = "ts_skins_shirt_inv.png",
	inventory_overlay = "ts_skins_jacket_high_viz_inv_overlay.png",
	colorable = true,
	default_color = dye_to_color("dye:orange"),
	recipe = {
		{ "wool:orange", "", "wool:orange" },
		{ "wool:yellow", "wool:grey", "wool:yellow" },
		{ "wool:orange", "wool:orange", "wool:orange" },
	}
})

ts_skins.register_clothing("trousers_high_viz", {
	type = "trousers",
	description = "High-visibility Trousers",
	skin = "ts_skins_trousers.png",
	skin_overlay = "ts_skins_trousers_high_viz_overlay.png",
	inventory_image = "ts_skins_trousers_inv.png",
	inventory_overlay = "ts_skins_trousers_high_viz_inv_overlay.png",
	colorable = true,
	default_color = dye_to_color("dye:orange"),
	recipe = {
		{ "wool:orange", "wool:orange", "wool:orange" },
		{ "wool:yellow", "", "wool:grey" },
		{ "wool:orange", "", "wool:orange" },
	}
})

ts_skins.register_clothing("trousers_santa", {
	type = "trousers",
	description = "Trousers (Santa)",
	skin = "ts_skins_trousers_santa.png",
	inventory_image = "ts_skins_trousers_santa_inv.png",
	recipe = {
		{ "wool:red", "wool:red", "wool:red" },
		{ "wool:red", "", "wool:red" },
		{ "wool:black", "", "wool:black" },
	}
})

ts_skins.register_clothing("jacket_santa", {
	type = "sweater",
	description = "Jacket (Santa)",
	skin = "ts_skins_jacket_santa.png",
	inventory_image = "ts_skins_jacket_santa_inv.png",
	recipe = {
		{ "wool:white", "", "wool:white" },
		{ "wool:red", "wool:white", "wool:red" },
		{ "wool:red", "wool:red", "wool:red" },
	}
})

ts_skins.register_clothing("hat_santa", {
	type = "hat",
	description = "Hat (Santa)",
	skin = "ts_skins_hat_santa.png",
	inventory_image = "ts_skins_hat_santa_inv.png",
	recipe = {
		{ "wool:red", "wool:red", "wool:red" },
		{ "", "wool:white", "" },
	}
})

ts_skins.register_clothing("beard_santa", {
	type = "face_accessory",
	description = "Fake Beard (Santa)",
	skin = "ts_skins_beard_santa.png",
	inventory_image = "ts_skins_beard_santa_inv.png",
	recipe = {
		{ "wool:white", "wool:white", "wool:white" },
		{ "", "wool:white", "" },
	}
})

ts_skins.register_clothing("dress", {
	type = "toga",
	description = "Dress",
	skin = "ts_skins_dress.png",
	inventory_image = "ts_skins_dress_inv.png",
	colorable = true,
	default_color = dye_to_color("dye:white"),
	recipe = {
		{ "", "farming:string", "" },
		{ "", "wool:white", "" },
		{ "", "wool:white", "" },
	}
})



minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	local stack
	if action == "move" and inventory_info.to_list and inventory_info.to_list == "ts_skins_clothing" then
		stack = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
	elseif action == "put" and inventory_info.listname and inventory_info.listname == "ts_skins_clothing" then
		stack = inventory_info.stack
	end
	if stack then
		return stack:get_definition()._ts_skins and 1 or 0
	end
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	local player_name = player:get_player_name()
	if inventory_info.from_list and inventory_info.from_list == "ts_skins_clothing"
		or inventory_info.to_list and inventory_info.to_list == "ts_skins_clothing"
		or inventory_info.listname and inventory_info.listname == "ts_skins_clothing"
	then
		ts_skins.update_skin(player_name)
		armor:update_skin(player_name)
		minetest.after(0.1, function()
			ts_skins.update_ui(player_name)
		end)
	end
end)