ts_skins.apple = true

ts_skins.storage_get = function(key, default)
	local value = ts_skins.storage:get_string(key)
	if value and value ~= "" then
		return value
	else
		return default
	end
end

function ts_skins.get_skin_tone(name)
	return ts_skins.storage_get(name.."_skin_tone", "#eeb479")
end

function ts_skins.set_skin_tone(name, color)
	ts_skins.storage:set_string(name.."_skin_tone", color)
	ts_skins.update_skin(name)
end

function ts_skins.get_eye_color(name)
	return ts_skins.storage_get(name.."_eye_color", "#0000EF")
end

function ts_skins.set_eye_color(name, color)
	ts_skins.storage:set_string(name.."_eye_color", color)
	ts_skins.update_skin(name)
end

function ts_skins.get_eye_type(name)
	return ts_skins.storage_get(name.."_eye_type", "normal")
end

function ts_skins.set_eye_type(name, type)
	ts_skins.storage:set_string(name.."_eye_type", type)
	ts_skins.update_skin(name)
end

function ts_skins.get_mouth_color(name)
	return ts_skins.storage_get(name.."_mouth_color", "#7C6F66")
end

function ts_skins.set_mouth_color(name, color)
	ts_skins.storage:set_string(name.."_mouth_color", color)
	ts_skins.update_skin(name)
end

function ts_skins.get_hair_color(name)
	return ts_skins.storage_get(name.."_hair_color", "#4E3012")
end

function ts_skins.set_hair_color(name, color)
	ts_skins.storage:set_string(name.."_hair_color", color)
	ts_skins.update_skin(name)
end

function ts_skins.get_hair_type(name)
	return ts_skins.storage_get(name.."_hair_type", "normal")
end

function ts_skins.set_hair_type(name, type)
	ts_skins.storage:set_string(name.."_hair_type", type)
	ts_skins.update_skin(name)
end

function ts_skins.get_body_features(name)
	return {
		skin_tone = ts_skins.get_skin_tone(name),
		eye_color = ts_skins.get_eye_color(name),
		eye_type = ts_skins.get_eye_type(name),
		mouth_color = ts_skins.get_mouth_color(name),
		hair_color = ts_skins.get_hair_color(name),
		hair_type = ts_skins.get_hair_type(name),
	}
end

function ts_skins.get_texture_for_stack(stack)
	local def = stack:get_definition()
	if not def._ts_skins then
		return nil, nil
	end
	local color = stack:get_meta():get_string("color")
	if not color or color == "" then
		color = def.color
	end
	if not color or color == "" then
		color = "#ffffff"
	end
	local texture = "("..def._ts_skins.skin.."^[multiply:"..color
	if def._ts_skins.skin_overlay then
		texture = texture .. "^"..def._ts_skins.skin_overlay
	end
	texture = texture .. ")"
	return def._ts_skins.type, texture
end

function ts_skins.get_clothing_textures(name)
	local l = {
		shoes = {},
		trousers = {},
		shirt = {},
		sweater = {},
		tie = {},
		toga = {},
		belt = {},
		jacket = {},
		cape = {},
		hat = {},
		glove = {},
		face_accessory = {}
	}

	if not minetest.player_exists(name) then
		return l
	end
	local inv = minetest.get_inventory({ type = "player", name = name })
	if not inv then
		return l
	end
	local list = inv:get_list("ts_skins_clothing")
	if not list then
		return l
	end
	for _,item in ipairs(list) do
		local clothing_type, texture = ts_skins.get_texture_for_stack(item)
		if clothing_type and texture then
			local t = l[clothing_type]
			if t and type(t) == "table" then
				t[#t+1] = texture
			end
		end
	end
	return l
end

function ts_skins.build_skin_texture(body, clothing)
	local empty = function(t) return next(t) == nil end
	local trouser_missing = empty(clothing.trousers) and empty(clothing.toga)
	local top_missing = empty(clothing.shirt) and empty(clothing.sweater) and empty(clothing.toga)

	-- Build skin texture
	local skin = "ts_skins_base.png^[colorize:"..body.skin_tone.."^ts_skins_shading.png"
	skin = skin .. "^(ts_skins_white.png^[colorize:"..body.eye_color.."^[resize:64x32^ts_skins_eyes_"..body.eye_type..".png^[makealpha:255,0,255)"
	skin = skin .. "^(ts_skins_mouth_normal.png^[colorize:"..body.mouth_color.."^[opacity:70)"

	if trouser_missing then
		skin = skin .. "^(ts_skins_shorts.png)"
	end
	if top_missing then
		skin = skin .. "^(ts_skins_tanktop.png)"
	end

	for _,texture in ipairs(clothing.face_accessory) do skin = skin .. "^"..texture end
	for _,texture in ipairs(clothing.shirt)          do skin = skin .. "^"..texture end
	for _,texture in ipairs(clothing.trousers)       do skin = skin .. "^"..texture end
	for _,texture in ipairs(clothing.tie)            do skin = skin .. "^"..texture end
	for _,texture in ipairs(clothing.sweater)        do skin = skin .. "^"..texture end
	for _,texture in ipairs(clothing.glove)          do skin = skin .. "^"..texture end
	for _,texture in ipairs(clothing.shoes)          do skin = skin .. "^"..texture end
	for _,texture in ipairs(clothing.toga)           do skin = skin .. "^"..texture end
	for _,texture in ipairs(clothing.jacket)         do skin = skin .. "^"..texture end
	for _,texture in ipairs(clothing.belt)           do skin = skin .. "^"..texture end
	for _,texture in ipairs(clothing.cape)           do skin = skin .. "^"..texture end

	if body.hair_type ~= "bald" then
		skin = skin .. "^(ts_skins_hair_"..body.hair_type..".png^[colorize:"..body.hair_color.."^ts_skins_hair_"..body.hair_type.."_shading.png)"
	end

	for _,texture in ipairs(clothing.hat)            do skin = skin .. "^"..texture end
	return skin
end

function ts_skins.update_skin(name)
	if not minetest.player_exists(name) then return end
	local body = ts_skins.get_body_features(name)
	local clothing = ts_skins.get_clothing_textures(name)
	local skin = ts_skins.build_skin_texture(body, clothing)
	ts_skins.storage:set_string("skin_"..name, skin)
end

function ts_skins.get_skin(name)
	return ts_skins.storage_get("skin_"..name, "character.png")
end

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	minetest.get_inventory({type = "player", name = player_name}):set_size("ts_skins_clothing", 9)
	ts_skins.update_skin(player_name)
end)
