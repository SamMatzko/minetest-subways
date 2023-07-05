-- Optional supported mods
local use_attachment_patch = advtrains_attachment_offset_patch and advtrains_attachment_offset_patch.setup_advtrains_wagon
local use_advtrains_livery_designer = minetest.get_modpath("advtrains_livery_designer") and advtrains_livery_designer
local mod_name = "subways_lrv_p3010"

-- The definitions for registering the wagon with advtrains
local subway_wagon_def = {
    mesh = "p3010.b3d",
    textures = {
        "p3010_exterior.png",
    },
 
    -- Texture variables used when changing livery, lights, and line numbers
    base_texture = "p3010_exterior.png",
    current_light_texture = "",
    light_texture_forwards = "p3010_light_forwards.png",
    light_texture_backwards = "p3010_light_backwards.png",

    -- This function is used to update the textures of the train based on a data table
    set_textures = function(self)
        self.object:set_properties({
            textures = {
                self.base_texture.."^"..self.current_light_texture,
            }
        })
    end,

    -- This function is called when the train's velocity changes
    -- It is used to update the exterior lights
    custom_on_velocity_change = function(self, velocity, old_velocity)
        if velocity ~= old_velocity then
            local data = advtrains.wagons[self.id]
            if velocity > 0 then
                if data.wagon_flipped then
                    self.current_light_texture = self.light_texture_backwards
                else
                    self.current_light_texture = self.light_texture_forwards
                end
            end
        end
    end,

    -- This function is called whenever the train is updated
    custom_on_step = function(self, dtime, data, train)
        self:set_textures()
    end,

    -- Train physical/interaction configuration
    collisionbox = {
	-1.0, -0.5, -1.0,
	1.0, 2.5, 1.0
    },
    coupler_types_back = {p3010 = true},
    coupler_types_front = {Tomlinson = true},
    is_locomotive = true,
    drives_on = {default = true},
    max_speed = 15,
    wagon_span = 3.15,

    -- Seat/user configuration
    assign_to_seat_group = {"driver_stand", "passenger"},
    seats = {
        {
            name="Driver stand",
            attach_offset={x=-4, y=0.5, z=18},
            view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=0.5, z=0},
            group="driver_stand",
        },
        {
            name="1",
            attach_offset={x=-4, y=0.5, z=10},-- 10
            view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=0.5, z=0},
            group="passenger",
        },
    },
    seat_groups = {
        driver_stand={
            name = "Driver Stand",
            access_to = {"passenger"},
            require_doors_open=true,
            driving_ctrl_access=true,
        },
        passenger={
            name = "Passenger Area",
            access_to = {"driver_stand"},
            require_doors_open=true,
        },
    },
}

-- Enable support for advtrains_attachment_offset_patch
if use_attachment_patch then
    advtrains_attachment_offset_patch.setup_advtrains_wagon(subway_wagon_def)
end

-- Register the subway wagon
advtrains.register_wagon("lrv_p3010", subway_wagon_def, "LRV P3010 (Subways)", "p3010_inv.png")

-- Crafting recipes
minetest.register_craft({
    output = "advtrains:lrv_p3010",
    recipe = {
        {"default:steelblock", "default:steelblock", "default:steelblock"},
        {"xpanes:pane_flat", "dye:yellow", "xpanes:pane_flat"},
        {"advtrains:wheel", "", "advtrains:wheel"}
    }
})
