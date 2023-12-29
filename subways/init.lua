-- Optional supported mods
subways.use_attachment_patch = advtrains_attachment_offset_patch and advtrains_attachment_offset_patch.setup_advtrains_wagon
local use_attachment_patch = subways.use_attachment_patch
local use_advtrains_livery_designer = minetest.get_modpath("advtrains_livery_designer") and advtrains_livery_designer

subways = {}
advtrains.register_coupler_type("tomlinson", "Tomlinson Coupler")

-- The main function that registers subway trains
function subways.register_subway(subway_def)

    -- The mod name for this particular subway
    local mod_name = subway_def.mod_name
    
    -- Register a custom coupler type, if one is defined
    if subway_def.custom_coupler then
        advtrains.register_coupler_type(subway_def.custom_coupler.name, subway_def.custom_coupler.human_name)
    end

    -- If the livery mod is installed, register this wagon with it
    if use_advtrains_livery_designer then

        -- The livery definitions
        local livery_template = subway_def.livery_temlate
        local predefined_livery = subway_def.predefined_livery

        -- The specific wgon name
        local wagon_type = mod_name..":hr4000"

        -- This function is called whenever the user presses the "Apply" button
        local function apply_wagon_livery_textures(player, wagon, textures)
            if wagon and textures and textures[1] then
                local data = advtrains.wagons[wagon.id]
                data.livery = textures[5]
                data.seat_livery = textures[3]
                wagon:set_textures(data)
            end
        end

        -- Register this mod and its livery function with the advtrains_livery_designer tool
        advtrains_livery_designer.register_mod(mod_name, apply_wagon_livery_textures)

        -- Register this particular wagon
        advtrains_livery_database.register_wagon(wagon_type, mod_name)

        -- Add the template and template overlays
        advtrains_livery_database.add_livery_template(
            wagon_type,
            livery_template.name,
            livery_template.base_textures,
            mod_name,
            (livery_template.overlays and #livery_template.overlays) or 0,
            livery_template.designer,
            livery_template.texture_license,
            livery_template.texture_creator,
            livery_template.notes
        )
        if livery_template.overlays then
            for overlay_id, overlay in ipairs(livery_template.overlays) do
                advtrains_livery_database.add_livery_template_overlay(
                    wagon_type,
                    livery_template.name,
                    overlay_id,
                    overlay.name,
                    overlay.slot_idx,
                    overlay.texture,
                    overlay.alpha
                )
            end
        end

        -- Register this mod's predefined wagon liveries
        local livery_design = predefined_livery.livery_design
        livery_design.wagon_type = wagon_type
        advtrains_livery_database.add_predefined_livery(
            predefined_livery.name,
            livery_design,
            mod_name,
            predefined_livery.notes
        )
    end

    -- This function updates the livery when the train is punched
    local function update_livery(self, puncher)
        local itemstack = puncher:get_wielded_item()
        local item_name = itemstack:get_name()
        if use_advtrains_livery_designer and item_name == advtrains_livery_designer.tool_name then
            advtrains_livery_designer.activate_tool(puncher, self, mod_name)
            return true
        end
        return false
    end

    -- Variables that need to be set before creating advtrains_def
    local assign_to_seat_group = {"passenger"}
    local seat_groups = {
        passenger = {
            name = "Passenger",
            access_to = {"driver_stand"},
            require_doors_open = true,
            driving_ctrl_access = false
        },
    }
    if subway_def.has_driver_stand then
        assign_to_seat_group = {"passenger", "driver_stand"}
        seat_groups = {
            driver_stand = {
                name = "Driver Stand",
                access_to = {"passenger"},
                require_doors_open = true,
                driving_ctrl_access = true,
            },
            passenger = {
                name = "Passenger",
                access_to = {"driver_stand"},
                require_doors_open = true,
                driving_ctrl_access = false
            },
        }
    end

    -- Create the final definitions used to register this wagon with Advanced Trains
    local advtrains_def = {
        mesh = subway_def.mesh,
        textures = subway_def.textures.bases,

        -- Texture variables used when changing livery, lights, and line numbers
        current_light_texture = "",
        light_texture_forwards = subway_def.light_texture_forwards,
        light_texture_backwrds = subway_def.light_texture_backwards,
        line_number = nil,
        livery = nil,

        -- This function checks if the train is being punched by the livery tool and, if so, activates it
        custom_may_destroy = function(self, puncher, tiem_from_last_punch, tool_capabilities, direction)
            return not update_livery(self, puncher)
        end,

        -- This function is called whenever the train is updated, and sets the line numbers
        custom_on_step = function(self, dtime, data, train)

            -- Set the line number variable
            local line_number = tonumber(train.line)
            if line_number and line_number <= 9 and line_number > 0 then
                self.line_number = train.line
            else
                self.line_number = nil
            end
            self:update_textures()
        end,

        -- This function is called when the train's velocity changes
        -- It is used to update the exterior lights
        custom_on_velocity_change = function(self, velocity, old_velocity)
            if velocity ~= old_velocity then
                local data = advtrains.wagons[self.id]
                if velocity > 0 then
                    if data.wagon_flipped then
                        self.current_light_texture = "^"..self.light_texture_backwards
                    else
                        self.current_light_texture = "^"..self.light_texture_forwards
                    end
                else
                    self.current_light_texture = ""
                end
            end
        end,

        -- Returns the proper associated livery or overlay from a string.
        -- The available builtin liveries are "livery" (for exterior livery) and "seat_livery"
        -- (for seat livery, duh). The available builtin overlays are "current_light" (for
        -- whatever lights/headlamps/etc. are active at the moment, and "line_number", for the
        -- currently displayed line number. If the provided string is none of these, just use it as
        -- an image reference.
        get_livery_or_overlay = function(self, livery)
            if livery == "livery" then return self.livery
            elseif livery == "seat_livery" then return self.seat_livery
            elseif livery == "current_light" then return self.current_light_texture
            elseif livery == "line_number" then return self.line_number_image
            else return livery end
        end,

        -- This function is used to update the textures of the train based on a data table
        set_textures = function(self, data)
            if data.livery then
                self.livery = data.livery
                self.seat_livery = data.seat_livery
                self:update_textures()
            end
        end,

        -- This function updates the textures based on the texture variables
        update_textures = function(self)

            -- Select the correct image for the line number
            local line_number_image = ""
            if self.line_number ~= nil then
                line_number_image = "^"..subway_def.name..self.line_number..".png"
            end

            -- Create the textures that are to be added to the train on update.
            -- This section handles arrangement and assignment of liveries and overlays.

            -- The array of textures
            local textures = {}

            -- Loop through the base textures and assign their respective liveries and overlays
            for i,base in subway_def.textures.bases do 

                -- Apply  the liveries, if available
                if self.livery then
                    local current_livery = subway_def.textures.liveries[i]
                    if current_livery then
                        textures[i] = self.get_livery_or_overlay(current_livery)
                    end

                -- Apply the overlays, if available
                else
                    local current_overlays = subway_def.textures.overlays
                    if current_overlays then
                        local total_overlays = base
                        for o,overlay in current_overlays do
                            total_overlays = total_overlays.."^"..self.get_livery_or_overlay(current_overlays[o])
                        end
                    end
                end
            end

            -- Apply the modified image textures
            self.object:set_properties({
                textures = textures
            })
        end,

        -- Train physical/interaction configuration
        collisionbox = subway_def.collisionbox,
        coupler_types_back = subway_def.coupler_types_back,
        coupler_types_front = subway_def.coupler_types_front,
        drives_on = {default = true},
        drops = {"default:steelblock 4"},
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
        is_locomotive = subway_def.is_locomotive,
        max_speed = 15,
        wagon_span = subway_def.wagon_span,
        wheel_positions = subway_def.wheel_positions,

        -- Seat/user configuration
        assign_to_seat_group = assign_to_seat_group,
        seats = subway_def.seats,
        seat_groups = seat_groups,
    }

    -- Enable support for advtrains_attachment_offset_patch
    if use_attachment_patch then
        advtrains_attachment_offset_patch.setup_advtrains_wagon(advtrains_def)
    end

    -- Register this subway wagon with advtrains
    advtrains.register_wagon(mod_name..subway_def.wagon_name, advtrains_def, subway_def.human_name, wagon_dev.inv_img)
end
