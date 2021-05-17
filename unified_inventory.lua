local player_fs_version = {}
local E = function (texture) return texture:gsub(",", "\\,") end
local ui_version = unified_inventory.version or 1

unified_inventory.register_button("ts_skins", {
	type = "image",
	image = "ts_skins_pullover_inv.png^[multiply:#00dd00",
	tooltip = "Skins and Clothing"
})

unified_inventory.register_page("ts_skins", {
	get_formspec = function(player, perplayer_formspec)
		local name = player:get_player_name()

		if not player_fs_version[name] then
			player_fs_version[name] = minetest.get_player_information(name).formspec_version or 1
		end

		local open_palette = ts_skins.get_open_palette(player:get_player_name(), 6.5, 0.5)
		local x = ui_version >= 2 and (perplayer_formspec.std_inv_x + unified_inventory.list_img_offset) or 0
		local fs = ""
		if ui_version >= 2 then
			fs = fs .. perplayer_formspec.standard_inv_bg
			fs = fs .. string.format("container[%f,%f]",
					perplayer_formspec.std_inv_x + unified_inventory.list_img_offset, perplayer_formspec.form_header_y)
			fs = fs .. unified_inventory.make_inv_img_grid(-unified_inventory.list_img_offset, 0.2, 3, 3)
			fs = fs .. "list[player:"..name..";ts_skins_clothing;0,"..(0.2+unified_inventory.list_img_offset)..";3,3;]"
		else
			fs = fs .. "container[0.5,"..perplayer_formspec.formspec_y.."]"
			fs = fs .. "background[-0.5,0;3,3;"..minetest.formspec_escape("ui_crafting_form.png^[sheet:2x1")..":0,0]"
			fs = fs .. "background[-0.5,3.5;8,4;ui_main_inventory.png]"
			fs = fs .. "list[player:"..name..";ts_skins_clothing;-0.5,0;3,3;]"
			fs = fs .. "real_coordinates[true]"
		end
		fs = fs .. "label[0,0;Clothing]"
		fs = fs .. "label[6,0;Body]"
		if player_fs_version[name] >= 4 then -- The model[] element is probably available
			local texture = E(armor.textures[name].skin)..","..E(armor.textures[name].armor)..","..E(armor.textures[name].wielditem)
			fs = fs .. "model["..(3.75 + (unified_inventory.list_img_offset or 0))..",0.5;2,3;m1;3d_armor_character.b3d;"..texture..";0,180;false;true;0,79]"
		end
		if open_palette then
			fs = fs .. open_palette
		else
			fs = fs .. "button[6,.3;2,.75;ts_skins_open_skin_tone_palette;Skin Tone]"
			fs = fs .. "button[6,1.15;2,.75;ts_skins_open_eye_color_palette;Eye Color]"
			fs = fs .. ts_skins.get_style_dropdown(8, 1.15, 2, .75, "eye_type", ts_skins.get_eye_type(name))
			fs = fs .. "button[6,2;2,.75;ts_skins_open_mouth_color_palette;Mouth Color]"
			fs = fs .. "button[6,2.85;2,.75;ts_skins_open_hair_color_palette;Hair Color]"
			fs = fs .. ts_skins.get_style_dropdown(8, 2.85, 2, .75, "hair_type", ts_skins.get_hair_type(name))
		end
		fs = fs .. "listring[current_player;main]"
		fs = fs .. "listring[player:"..name..";ts_skins_clothing]"
		if ui_version < 2 then
			fs = fs .. "real_coordinates[false]"
		end
		fs = fs .. "container_end[]"
		return {
			formspec = fs
		}
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if fields.ts_skins_open_skin_tone_palette then
		ts_skins.open_palettes[name] = "skin_tones"
	elseif fields.ts_skins_open_eye_color_palette then
		ts_skins.open_palettes[name] = "eye_colors"
	elseif fields.ts_skins_open_mouth_color_palette then
		ts_skins.open_palettes[name] = "mouth_colors"
	elseif fields.ts_skins_open_hair_color_palette then
		ts_skins.open_palettes[name] = "hair_colors"
	elseif fields.ts_skins_close_palette then
		ts_skins.open_palettes[name] = nil
	end

	for k,v in pairs(fields) do
		if k:sub(1,8) == "ts_skins" then
			minetest.after(0, function()
				ts_skins.update_ui(name)
			end)
		end
	end
end)