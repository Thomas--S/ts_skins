local function update_fs(pos)
    local meta = minetest.get_meta(pos)
    local fs = "formspec_version[3]"
    fs = fs.."size[14.5,13.5]"
    local y = .5
    for i = 1,5 do
        fs = fs.."label[.5,"..(y+.5)..";Slot "..i.."]"
        fs = fs.."image_button[1.75,"..y..";1,1;ts_skins_swap.png;swap"..i..";]"
        fs = fs.."tooltip[swap"..i..";Swap current clothing with slot "..i.."]"
        fs = fs.."list[context;slot"..i..";3,"..y..";9,1]"
        y = y + 1.25
    end
    fs = fs.."box[.375,"..(y-.125)..";13.75,1.25;#fff3]"
    fs = fs.."label[.5,"..(y+.5)..";Current Clothing]"
    fs = fs.."list[current_player;ts_skins_clothing;3,"..y..";9,1]"
    y = y + 1.5
    fs = fs.."list[current_player;main;3,"..y..";8,4]"
    fs = fs.."listring[]"
    meta:set_string("formspec", fs)
end

minetest.register_node("ts_skins:wardrobe", {
    description = "Wardrobe",
    tiles = { "default_wood.png^[transformR90" },
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { choppy = 2, oddly_breakable_by_hand = 2 },
    node_box = {
        type = "fixed",
        fixed = {
            { -.9, -.5, -.4, .9, 1.5, .5},
            { -.8, 0, -.45, -.05, 1.4, -.4},
            { .05, 0, -.45, .8, 1.4, -.4},
            { -.8, -.35, -.45, -.05, -.1, -.4},
            { .05, -.35, -.45, .8, -.1, -.4},
            { -.25, .65, -.5, -.15, .75, -.45},
            { .15, .65, -.5, .25, .75, -.45},
        }
    },
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("slot1", 9)
        inv:set_size("slot2", 9)
        inv:set_size("slot3", 9)
        inv:set_size("slot4", 9)
        inv:set_size("slot5", 9)
        update_fs(pos)
    end,
    on_rightclick = function(pos)
        update_fs(pos)
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        local player_name = sender:get_player_name()
        if fields.quit or minetest.is_protected(pos, player_name) then
            return
        end
        for i = 1,5 do
            if fields["swap"..i] then
                local meta = minetest.get_meta(pos)
                local node_inv = meta:get_inventory()
                local player_inv = sender:get_inventory()
                if not node_inv or not player_inv then
                    return
                end
                local slot_list = node_inv:get_list("slot"..i)
                local player_clothing_list = player_inv:get_list("ts_skins_clothing")
                node_inv:set_list("slot"..i, player_clothing_list)
                player_inv:set_list("ts_skins_clothing", slot_list)
                ts_skins.update_skin(player_name)
                armor:update_skin(player_name)
            end
        end
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if minetest.is_protected(pos, player:get_player_name()) then
            return 0
        end
        return count
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if minetest.is_protected(pos, player:get_player_name()) then
            return 0
        end
        if stack then
            return stack:get_definition()._ts_skins and 1 or 0
        end
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if minetest.is_protected(pos, player:get_player_name()) then
            return 0
        end
        if stack then
            return stack:get_definition()._ts_skins and 1 or 0
        end
    end,
    can_dig = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        for i=1,5 do
            if not inv:is_empty("slot"..i) then
                return false
            end
        end
        return true
    end,
    sounds = default.node_sound_wood_defaults()
})

minetest.register_craft({
    output = "ts_skins:wardrobe",
    recipe = {
        {"default:wood", "default:stick", "default:wood"},
        {"default:wood", "", "default:wood"},
        {"default:wood", "default:chest_locked", "default:wood"},
    },
})