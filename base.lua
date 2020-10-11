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

function ts_skins.update_skin(name)
	if not minetest.player_exists(name) then return end
	-- Body
	local skin_tone = ts_skins.get_skin_tone(name)
	local eye_color = ts_skins.get_eye_color(name)
	local eye_type = ts_skins.get_eye_type(name)
	local mouth_color = ts_skins.get_mouth_color(name)
	local hair_color = ts_skins.get_hair_color(name)
	local hair_type = ts_skins.get_hair_type(name)

	-- Clothing
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

	local inv = minetest.get_inventory({ type = "player", name = name })
	if not inv then return end
	local list = inv:get_list("ts_skins_clothing")
	if not list then return end
	for _,item in ipairs(list) do
		local def = item:get_definition()
		if def._ts_skins then
			local color = item:get_meta():get_string("color")
			if not color or color == "" then
				color = def.color
			end
			if not color or color == "" then
				color = "#ffffff"
			end
			local t = l[def._ts_skins.type]
			if t and type(t) == "table" then
				local texture = "("..def._ts_skins.skin.."^[multiply:"..color
				if def._ts_skins.skin_overlay then
					texture = texture .. "^"..def._ts_skins.skin_overlay
				end
				texture = texture .. ")"
				t[#t+1] = texture
			end
		end
	end

	local empty = function(t) return next(t) == nil end
	local trouser_missing = empty(l.trousers) and empty(l.toga)
	local top_missing = empty(l.shirt) and empty(l.sweater) and empty(l.toga)

	-- Build skin texture
	local skin = "ts_skins_base.png^[colorize:"..skin_tone.."^ts_skins_shading.png"
	skin = skin .. "^(ts_skins_white.png^[colorize:"..eye_color.."^[resize:64x32^ts_skins_eyes_"..eye_type..".png^[makealpha:255,0,255)"
	skin = skin .. "^(ts_skins_mouth_normal.png^[colorize:"..mouth_color.."^[opacity:70)"

	if trouser_missing then
		skin = skin .. "^(ts_skins_shorts.png)"
	end
	if top_missing then
		skin = skin .. "^(ts_skins_tanktop.png)"
	end

	for _,texture in ipairs(l.face_accessory) do skin = skin .. "^"..texture end
	for _,texture in ipairs(l.shirt)          do skin = skin .. "^"..texture end
	for _,texture in ipairs(l.trousers)       do skin = skin .. "^"..texture end
	for _,texture in ipairs(l.tie)            do skin = skin .. "^"..texture end
	for _,texture in ipairs(l.sweater)        do skin = skin .. "^"..texture end
	for _,texture in ipairs(l.glove)          do skin = skin .. "^"..texture end
	for _,texture in ipairs(l.jacket)         do skin = skin .. "^"..texture end
	for _,texture in ipairs(l.shoes)          do skin = skin .. "^"..texture end
	for _,texture in ipairs(l.toga)           do skin = skin .. "^"..texture end
	for _,texture in ipairs(l.belt)           do skin = skin .. "^"..texture end
	for _,texture in ipairs(l.cape)           do skin = skin .. "^"..texture end

	if hair_type ~= "bald" then
		skin = skin .. "^(ts_skins_hair_"..hair_type..".png^[colorize:"..hair_color.."^ts_skins_hair_"..hair_type.."_shading.png)"
	end

	for _,texture in ipairs(l.hat)            do skin = skin .. "^"..texture end

	-- Save
	ts_skins.storage:set_string("skin_"..name, skin)
end

function ts_skins.get_skin(name)
	return ts_skins.storage_get("skin_"..name, "character.png")
end

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	minetest.get_inventory({type = "player", name = player_name}):set_size("ts_skins_clothing", 6)
	ts_skins.update_skin(player_name)
end)
