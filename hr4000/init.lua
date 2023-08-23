-- Optional supported mods
local use_attachment_patch = advtrains_attachment_offset_patch and advtrains_attachment_offset_patch.setup_advtrains_wagon
local use_advtrains_livery_designer = minetest.get_modpath("advtrains_livery_designer") and advtrains_livery_designer
local mod_name = "subways_hr4000"

-- The livery template definition
local livery_template = {
    name = "HR4000",
    designer = "Sylvester Kruin",
    texture_license = "CC-BY-SA-3.0",
    texture_creator = "Sylvester Kruin",
    notes = "This template supports independent color overrides for the exterior accents and seats.",
    base_textures = {
        "hr4000_coupler.png",
        "hr4000_doors.png",
        "hr4000_seats.png",
        "hr4000_undercarriage.png",
        "hr4000_exterior.png",
        "hr4000_interior.png",
        "hr4000_wheels.png"
    },
    overlays = {
        [1] = {name = "Exterior Accents", slot_idx = 5, texture = "hr4000_exterior_overlay.png", alpha = 255},
        [2] = {name = "Seat Accents", slot_idx = 3, texture = "hr4000_seats_overlay.png", alpha = 255},
    }
}

-- Predefined liveries
local predefined_livery = {
    name = "Standard Yellow",
    notes = "The default yellow color scheme",
    livery_design = {
        livery_template_name = "HR4000",
        overlays = {
            [1] = {id = 1, color = "#FFFF00"},
            [2] = {id = 2, color = "#E5C21C"},
        }
    }
}

-- If the livery mod is installed, register the wagon with it
if use_advtrains_livery_designer then

    -- The specific wagon name
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

-- The definitions for registering the subway wagon with advtrains
local subway_wagon_def = {
    mesh = "hr4000.b3d",
    textures = {
        "hr4000_coupler.png",
        "hr4000_doors.png",
        "hr4000_seats.png",
        "hr4000_undercarriage.png",
        "hr4000_exterior.png",
        "hr4000_interior.png",
        "hr4000_wheels.png"
    },

    -- Texture variables used when changing livery, lights, and line numbers
    base_texture = "hr4000_exterior.png",
    current_light_texture = "",
    light_texture_forwards = "hr4000_light_forwards.png",
    light_texture_backwards = "hr4000_light_backwards.png",
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

    -- Add optional support for the bike painter, in case users don't want to use the livery mod
    set_livery = function(self, puncher, itemstack, data)
        local meta = itemstack:get_meta()
        local color = meta:get_string("paint_color")
        local alpha = tonumber(meta:get_string("alpha"))
        if color and color:find("^#%x%x%x%x%x%x$") then
            data.livery = self.base_texture.."^("..self.base_livery.."^[colorize:"..color..":255)"
            self:set_textures(data)
        end
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
            line_number_image = "^hr4000_line"..self.line_number..".png"
        end
        if self.livery then
            self.object:set_properties({
                textures = {
                    "hr4000_coupler.png",
                    "hr4000_doors.png",
                    self.seat_livery,
                    "hr4000_undercarriage.png",
                    self.livery.."^hr4000_exterior_overlay_overlay.png"..self.current_light_texture..line_number_image,
                    "hr4000_interior.png",
                    "hr4000_wheels.png"
                }
            })
        else
            self.object:set_properties({
                textures = {
                    "hr4000_coupler.png",
                    "hr4000_doors.png",
                    "hr4000_seats.png",
                    "hr4000_undercarriage.png",
                    "hr4000_exterior.png".."^hr4000_exterior_overlay_overlay.png"..self.current_light_texture..line_number_image,
                    "hr4000_interior.png",
                    "hr4000_wheels.png",
                }
            })
        end
    end,

    -- Train physical/interaction configuration
    collisionbox = {
	-1.0, -0.5, -1.0,
	1.0, 2.5, 1.0
    },
    coupler_types_back = {hr4000 = true},
    coupler_types_front = {Tomlinson = true},
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
    is_locomotive = true,
    max_speed = 15,
    wagon_span = 3.15,
    wheel_positions = {2, -2},

    -- Seat/user configuration
    assign_to_seat_group = {"passenger", "driver_stand"},
    seats = {
        {
            name = "Driver stand",
            attach_offset = {x = -5, y = 2, z = 24},
            view_offset = use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "driver_stand",
        },
        {
            name = "1",
            attach_offset = {x = -5, y = 2, z = 8},
            view_offset = use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "2",
            attach_offset = {x = 5, y = 2, z = 8},
            view_offset = use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "3",
            attach_offset = {x = -5, y = 2, z = 0},
            view_offset = use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "4",
            attach_offset = {x = 5, y = 2, z = 0},
            view_offset = use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "5",
            attach_offset = {x = -5, y = 2, z = -8},
            view_offset = use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "6",
            attach_offset = {x = 5, y = 2, z = -8},
            view_offset = use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "7",
            attach_offset = {x = -5, y = 2, z = -25},
            view_offset = use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "8",
            attach_offset = {x = 5, y = 2, z = -25},
            view_offset = use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
    },
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
    },
}

-- Enable support for advtrains_attachment_offset_patch
if use_attachment_patch then
    advtrains_attachment_offset_patch.setup_advtrains_wagon(subway_wagon_def)
end

-- Register the subway wagon
advtrains.register_wagon(mod_name..":hr4000", subway_wagon_def, "HR4000 (Subways)", "hr4000_inv.png")

-- Crafting recipes
minetest.register_craft({
    output = mod_name..":hr4000",
    recipe = {
        {"default:steelblock", "default:steelblock", "default:steelblock"},
        {"xpanes:pane_flat", "dye:yellow", "xpanes:pane_flat"},
        {"advtrains:wheel", "dye:yellow", "advtrains:wheel"}
    }
})
