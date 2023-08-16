-- Optional supported mods
local use_attachment_patch = advtrains_attachment_offset_patch and advtrains_attachment_offset_patch.setup_advtrains_wagon
local use_advtrains_livery_designer = minetest.get_modpath("advtrains_livery_designer") and advtrains_livery_designer
local mod_name = "subways_hr4000"

-- The definitions for registering the subway wagon with advtrains
local subway_wagon_def = {
    mesh = "hr4000.b3d",
    textures = {
        "hr4000_coupler.png",
        "hr4000_seat.png",
        "hr4000_undercarriage.png",
        "hr4000_exterior.png",
        "hr4000_interior.png",
        "hr4000_wheels.png"
    },

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
            name = "Driver Stand",
            attach_offset = {x = 0, y = 2, z = 22},
            view_offset = use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "driver_stand",
        },
        {
            name = "1",
            attach_offset = {x = 0, y = 2, z = 0},
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
advtrains.register_wagon("hr4000", subway_wagon_def, "HR4000 (Subways)", "hr4000_inv.png")

-- Crafting recipes
minetest.register_craft({
    output = "advtrains:hr4000",
    recipe = {
        {"default:steelblock", "default:steelblock", "default:steelblock"},
        {"xpanes:pane_flat", "dye:yellow", "xpanes:pane_flat"},
        {"advtrains:wheel", "dye:yellow", "advtrains:wheel"}
    }
})
