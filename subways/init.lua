subways = {}
local modpath = minetest.get_modpath("subways")

-- Register the Tomlinson coupler
advtrains.register_coupler_type("tomlinson", "Tomlinson Coupler")

-- Variables for optional mod availability
subways.use_advtrains_livery_designer = minetest.get_modpath("advtrains_livery_designer") and advtrains_livery_designer
subways.use_attachment_patch = advtrains_attachment_offset_patch and advtrains_attachment_offset_patch.setup_advtrains_wagon

-- The font used for the displays
local font = unicode_text.hexfont({
    background_color = {0, 0, 0, 0},
    foreground_color = {255, 255, 255, 255},
    kerning = false,
})
font:load_glyphs(io.lines(modpath.."/unifont.hex"))
font:load_glyphs(io.lines(modpath.."/unifont_upper.hex"))
font:load_glyphs(io.lines(modpath.."/plane00csur.hex"))
font:load_glyphs(io.lines(modpath.."/plane0Fcsur.hex"))

-- Escapes an image string so it can be used as an image
local function escape_image_string(s)
    return string.gsub(s, "[:[^]", function (x)
        return "\\"..x
    end)
end

-- Joins the key/value pairs of two tables into one table.
local function join_tables(table1, table2)
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
        current_light_texture = "",
        displays = subway_def.displays or {},
        line = nil,
        livery = nil,
        text_outside = nil,

        -- Functions for controlling the behavior of the wagon.

        -- Checks if the train is being punched by the livery tool and, if so, activates it.
        custom_may_destroy = function(self, puncher, time_from_last_punch, tool_capabilities, direction)
            return not update_livery(self, puncher)
        end,

        -- Runs every step. Updates train data and textures as needed.
        custom_on_step = function(self, dtime, data, train)

            -- Update the train line and outside text
            if self.line ~= train.line or self.text_outsdie ~= train.text_outside then
                self.line = train.line
                self.text_outside = train.text_outside
                self:update_textures(true)
            end
        end,

        -- Used to update the train's lights
        custom_on_velocity_change = function(self, velocity, old_velocity)
            if velocity ~= old_velocity and (velocity == 0 or old_velocity == 0) then
                local data = advtrains.wagons[self.id]
                if velocity > 0 then
                    if data.wagon_flipped then
                        self.current_light_texture = self.light_texture_backwards
                    else
                        self.current_light_texture = self.light_texture_forwards
                    end
                else
                    self.current_light_texture = ""
                end
                self:update_textures()
            end
        end,

        -- Used to update the textures of the train based on the data table
        set_textures = function(self, data)
            if data.livery then
                self.livery = data.livery
                self:update_textures()
            end
        end,

        -- Updates the wagon's textures based on the texture variables.
        update_textures = function(self, update_text)

            -- Used to set the textures
            local old_props = self.object:get_properties()
            local textures

            -- The livery
            if self.livery then
                textures = {self.livery}
            else
                textures = {self.base_texture}
            end

            -- The lights
            if self.current_light_texture ~= "" then
                textures[1] = "[combine:"
                    ..self.base_texture_size
                    .."x"
                    ..self.base_texture_size
                    ..":0,0=("
                    ..escape_image_string(textures[1])
                    .."):"
                    ..self.light_texture_pos.x
                    ..","
                    ..self.light_texture_pos.y
                    .."="
                    ..self.current_light_texture
            end

            -- The displays
            for _, display in ipairs(self.displays) do
                local text

                if display.display == "line" then
                    text = self.line
                elseif display.display == "outside_first_line" then
                    -- Get first line of outside text
                    local _, _, matched = string.find(self.text_outside, "([^\n]*)\n?.*")
                    text = matched or ""
                else
                    error("Unexpected display type " .. display.display)
                end

                -- unicode_text has a bug that doesn't allow strings starting with numbers.
                local offset = 0
                if text and text:sub(1,1):match("%d") then
                    text = " "..text
                    offset = 8
                end

                -- Only update the text if the line has changed
                if update_text then

                    -- Create the text texture
                    local image = tga_encoder.image(font:render_text(text or " "))
                    image:encode({
                        colormap = {},
                        compression = "RLE",
                        color_format = "B8G8R8A8",
                    })
                    local height = image.height
                    local width = image.width
                    local image_string = minetest.encode_base64(image.data)
                    local display_texture = "\\[png\\:"..image_string.."\\^\\[multiply\\:#FFBB00"
                    local x_pos = math.floor((display.background_size - width) / 2)

                    -- Place the text texture
                    textures[display.slot] = "[combine:"
                        ..display.background_size
                        .."x"
                        ..display.background_size
                        ..":0,0=subways_displays.png:"
                        ..(x_pos - offset)
                        ..","
                        ..display.offset.y
                        .."=("
                        ..display_texture
                        ..")"
                else
                    -- Just use the texture that's already there
                    textures[display.slot] = old_props.textures[display.slot]
                end
            end

            -- Apply the textures
            self.object:set_properties({textures = textures})
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
