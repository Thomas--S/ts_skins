ts_skins.open_palettes = {}
ts_skins.palettes = {}
ts_skins.styles = {}
ts_skins.styles_index = {}

ts_skins.palettes.skin_tones = {
	desc = "Skin Tone",
	name = "skin_tone",
	colors = {
		"#F6E0D3", "#FFEACF", "#F9D7CA", "#FFDEB6", "#FFDAB4",
		"#FFDBAC", "#FFD29D", "#D6B187", "#F4B78D", "#F1C27D",
		"#E3A88F", "#EEB479", "#F4A989", "#E0AC69", "#C69076",
		"#BD8463", "#C68642", "#AF6E51", "#8D5524", "#843722",
		"#743F31", "#603F35", "#442C27", "#260701", "#3D0C02",
	},
}

ts_skins.palettes.eye_colors = {
	desc = "Eye Color",
	name = "eye_color",
	colors = {
		"#A61E10", "#0000EF", "#343471", "#4B6D0A", "#6D400B",
		"#2A1905", "#4C6157",
	}
}

ts_skins.palettes.hair_colors = {
	desc = "Hair Color",
	name = "hair_color",
	colors = {
		"#CEC8B0", "#E2A125", "#B8640E", "#804f1E", "#4E3012",
		"#2B1814", "#D83304", "#D80416", "#FF00F8", "#4E13E4",
		"#2AD1FD", "#0DDC3A",
	}
}

ts_skins.palettes.mouth_colors = {
	desc = "Mouth Color",
	name = "mouth_color",
	colors = {
		"#7C6F66", "#C4353F", "#DD2BC0",
	}
}

ts_skins.styles.eye_type = {
	"normal", "high", "big"
}

ts_skins.styles.hair_type = {
	"normal", "bald", "bald_patch", "medium", "long"
}

for name,def in pairs(ts_skins.styles) do
	ts_skins.styles_index[name] = {}
	for idx,val in ipairs(def) do
		ts_skins.styles_index[name][val] = idx
	end
end

function ts_skins.get_open_palette(name, x, y)
	local palette_name = ts_skins.open_palettes[name]
	local palette = ts_skins.palettes[palette_name]
	if not palette then
		return nil
	end
	local fs = "container["..x..","..y.."]"
	fs = fs .. "label[0.1,0.25;"..minetest.formspec_escape(palette.desc).."]"
	fs = fs .. "box[0,0;2.6,.5;#000000]"
	fs = fs .. "style[ts_skins_close_palette;bgcolor=red]"
	fs = fs .. "button[2.6,0;.5,.5;ts_skins_close_palette;x]"
	fs = fs .. "box[0,.5;3.1,"..math.ceil(#palette.colors / 5)*.6+.1 ..";#777777]"
	for i,c in ipairs(palette.colors) do
		local bx = ((i-1) % 5) * 0.6 + 0.1
		local by = math.floor((i-1) / 5) * 0.6 + 0.6
		fs = fs .. "image_button["..bx..","..by..";.5,.5;ts_skins_white.png^[colorize:"..c..";ts_skins_set_"..palette.name.."_"..c..";]"
	end
	fs = fs .. "container_end[]"
	return fs
end

function ts_skins.get_style_dropdown(x, y, w, h, style, current_value)
	if not ts_skins.styles[style] then
		return ""
	end
	local selected_idx = ts_skins.styles_index[style][current_value] or 1
	local fs = "dropdown["..x..","..y..";"..w..","..h..";ts_skins_set_style_"..style..";"
	fs = fs .. table.concat(ts_skins.styles[style], ",")
	fs = fs .. ";"..selected_idx.."]"
	return fs
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	for k,v in pairs(fields) do
		if k:starts_with("ts_skins_set_skin_tone_") then
			ts_skins.set_skin_tone(name, k:gsub("ts_skins_set_skin_tone_", ""))
		end
		if k:starts_with("ts_skins_set_eye_color_") then
			ts_skins.set_eye_color(name, k:gsub("ts_skins_set_eye_color_", ""))
		end
		if k:starts_with("ts_skins_set_mouth_color_") then
			ts_skins.set_mouth_color(name, k:gsub("ts_skins_set_mouth_color_", ""))
		end
		if k:starts_with("ts_skins_set_hair_color_") then
			ts_skins.set_hair_color(name, k:gsub("ts_skins_set_hair_color_", ""))
		end
	end
	if fields.ts_skins_set_style_eye_type then
		ts_skins.set_eye_type(name, fields.ts_skins_set_style_eye_type)
	end
	if fields.ts_skins_set_style_hair_type then
		ts_skins.set_hair_type(name, fields.ts_skins_set_style_hair_type)
	end
end)