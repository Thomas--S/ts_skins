local player_fs_version = {}
local E = function (texture) return texture:gsub(",", "\\,") end

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

		local fy = perplayer_formspec.formspec_y
		local open_palette = ts_skins.get_open_palette(player:get_player_name(), 6.5, 0.5)
		local fs = "background[0,"..fy..";3,3;ui_crafting_form.png^[sheet:2x1:0,0]"
		fs = fs .. "background[0,"..(fy + 3.5)..";8,4;ui_main_inventory.png]"
		fs = fs .. "container[0,"..fy.."]"
		fs = fs .. "list[player:"..name..";ts_skins_clothing;0,0;3,3;]"
		fs = fs .. "real_coordinates[true]"
		fs = fs .. "label[0.5,0;Clothing]"
		fs = fs .. "label[6.5,-0.25;Body]"
		if player_fs_version[name] >= 4 then -- The model[] element is probably available
			local texture = E(armor.textures[name].skin)..","..E(armor.textures[name].armor)..","..E(armor.textures[name].wielditem)
			fs = fs .. "model[4.25,0.5;2,3;m1;3d_armor_character.b3d;"..texture..";0,180;false;true;0,79]"
		end
		if open_palette then
			fs = fs .. open_palette
		else
			fs = fs .. "button[6.5,.1;2,.75;ts_skins_open_skin_tone_palette;Skin Tone]"
			fs = fs .. "button[6.5,0.95;2,.75;ts_skins_open_eye_color_palette;Eye Color]"
			fs = fs .. ts_skins.get_style_dropdown(8.5, 0.95, 2, .75, "eye_type", ts_skins.get_eye_type(name))
			fs = fs .. "button[6.5,1.8;2,.75;ts_skins_open_mouth_color_palette;Mouth Color]"
			fs = fs .. "button[6.5,2.65;2,.75;ts_skins_open_hair_color_palette;Hair Color]"
			fs = fs .. ts_skins.get_style_dropdown(8.5, 2.65, 2, .75, "hair_type", ts_skins.get_hair_type(name))
		end
		fs = fs .. "listring[current_player;main]"
		fs = fs .. "listring[player:"..name..";ts_skins_clothing]"
		fs = fs .. "real_coordinates[false]"
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
	minetest.after(0, function()
		ts_skins.update_ui(name)
	end)
end)