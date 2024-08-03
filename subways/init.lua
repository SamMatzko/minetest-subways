subways = {}

-- Register the Tomlinson coupler
advtrains.register_coupler_type("tomlinson", "Tomlinson Coupler")

-- Variables for optional mod availability
subways.use_advtrains_livery_designer = minetest.get_modpath("advtrains_livery_designer") and advtrains_livery_designer
subways.use_attachment_patch = advtrains_attachment_offset_patch and advtrains_attachment_offset_patch.setup_advtrains_wagon

-- Joins the key/value pairs of two tables into one table.
function join_tables(table1, table2)
    local new_table = {}
    for k, v in pairs(table1) do
        new_table[k] = v
    end
    for k, v in pairs(table2) do
        new_table[k] = v
    end
    return new_table
end

-- Register a subway wagon. Handles all the shared functions and things
function subways.register_subway(name, subway_def, readable_name, inv_image)

    -- The "mod name" is really just the name of the subway wagon.
    -- The livery designer requires one template for each "mod".
    local mod_name = "subways_"..name

    -- If the livery mod is installed, register this wagon with it
    if subways.use_advtrains_livery_designer then

        -- The specific wagon name
        local wagon_name = mod_name..":"..name
        local livery_template = subway_def.livery_def.livery_template
        local predefined_livery = subway_def.livery_def.predefined_livery

        -- This function is called whenever the user presses the "Apply" button
        local function apply_wagon_livery_textures(player, wagon, textures)
            if wagon and textures and #textures then
                local data = advtrains.wagons[wagon.id]
                data.livery = textures[1]
                wagon:set_textures(data)
            end
        end

        -- Register this mod and its livery function with the advtrains_livery_designer tool
        advtrains_livery_designer.register_mod(mod_name, apply_wagon_livery_textures)

        -- Register this particular wagon
        advtrains_livery_database.register_wagon(wagon_name, mod_name)

        -- Add the template and the template overlays
        advtrains_livery_database.add_livery_template(
            wagon_name,
            livery_template.name,
            livery_template.base_textures,
            mod_name,
            #livery_template.overlays or 0,
            livery_template.designer,
            livery_template.texture_license,
            livery_template.texture_creator,
            livery_template.notes)
        if livery_template.overlays then
            for overlay_id, overlay in ipairs(livery_template.overlays) do
                advtrains_livery_database.add_livery_template_overlay(
                    wagon_name,
                    livery_template.name,
                    overlay_id,
                    overlay.name,
                    overlay.slot_idx,
                    overlay.texture,
                    overlay.alpha)
            end
        end

        -- Register this mod's predifined wagon liveries
        local livery_design = predefined_livery.livery_design
        livery_design.wagon_type = wagon_name
        advtrains_livery_database.add_predefined_livery(
            predefined_livery.name,
            livery_design,
            mod_name,
            predefined_livery.notes)
    end

    -- This function updates the livery when the train is punched
    local function update_livery(self, puncher)
        local itemstack = puncher:get_wielded_item()
        local item_name = itemstack:get_name()
        if subways.use_advtrains_livery_designer and item_name == advtrains_livery_designer.tool_name then
            advtrains_livery_designer.activate_tool(puncher, self, mod_name)
            return true
        end
        return false
    end

    -- The definitions shared by all trains
    local advtrains_def = {

        -- Wagon configuration variables
        doors = {
            open = {
                [-1] = {frames = {x = 1, y = 20}, time = 1},
                [1] = {frames = {x = 40, y = 60}, time = 1},
            },
            close = {
                [-1] = {frames = {x = 20, y = 40}, time = 1},
                [1] = {frames = {x = 60, y = 80}, time = 1},
            }
        },
        drives_on = {default = true},

        -- Variables used when updating the appearance of the train
        livery = nil,

        -- Functions for controlling the behavior of the wagon.

        -- Checks if the train is being punched by the livery tool and, if so, activates it.
        custom_may_destroy = function(self, puncher, time_from_last_punch, tool_capabilities, direction)
            return not update_livery(self, puncher)
        end,

        -- Used to update the textures of the train based on the data table
        set_textures = function(self, data)
            if data.livery then
                self.livery = data.livery
                self:update_textures()
            end
        end,

        -- Updates the wagon's textures based on the texture variables.
        update_textures = function(self)
            if self.livery then
                self.object:set_properties({textures = {self.livery}})
            else
                self.object:set_properties({textures = {self.base_texture}})
            end
        end,
    }

    -- The complete definition table for the train.
    local complete_def = join_tables(subway_def.wagon_def, advtrains_def)

    -- Support for the attachment offset patch
    if subways.use_attachment_patch then
        advtrains_attachment_offset_patch.setup_advtrains_wagon(complete_def)
    end

    -- Register the crafting recipe and drops
    -- For now, this only supports default
    if default and minetest.get_modpath("default") then
        minetest.register_craft(subway_def.craft)
        complete_def.drops = {"default:steelblock 2"}
    end

    -- Register the train with AdvTrains.
    advtrains.register_wagon(mod_name..":"..name, complete_def, readable_name, inv_image)
end
