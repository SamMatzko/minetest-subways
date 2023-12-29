-- The defintions for registering this subway wagon with subways
local subway_wagon_def = {
    mod_name = "subways_hr4000",
    name = "hr4000",
    human_name = "HR4000 (Subways)",
    livery_template = {
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
    },
    predefined_livery = {
        name = "Standard Yellow",
        notes = "The default yellow color scheme",
        livery_design = {
            livery_template_name = "HR4000",
            overlays = {
                [1] = {id = 1, color = "#FFFF00"},
                [2] = {id = 2, color = "#E5C21C"},
            }
        }
    },
    has_driver_stand = true,
    mesh = "hr4000.b3d",
    textures = {
        bases = {
            "hr4000_coupler.png",
            "hr4000_doors.png",
            "hr4000_seats.png",
            "hr4000_undercarriage.png",
            "hr4000_exterior.png",
            "hr4000_interior.png",
            "hr4000_wheels.png"
        },
        liveries = {
            [3] = "seat_livery",
            [5] = "livery",
        },
        overlays = {
            [5] = {"hr4000_exterior_overlay_overlay.png", "current_light", "line_number"},
        },
    },
    light_texture_forwards = "hr4000_light_forwards.png",
    light_texture_backwards = "hr4000_light_backwards.png",
    inv_img = "hr4000_inv.png",
    collisionbox = {
	-1.0, -0.5, -1.0,
	1.0, 2.5, 1.0
    },
    custom_coupler = {name = "hr4000", human_name = "HR4000 Coupler"},
    coupler_types_back = {hr4000 = true},
    coupler_types_front = {tomlinson = true},
    is_locomotive = true,
    wagon_span = 3.15,
    wheel_positions = {2, -2},
    seats = {
        {
            name = "Driver stand",
            attach_offset = {x = -5, y = 2, z = 24},
            view_offset = subways.use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "driver_stand",
        },
        {
            name = "1",
            attach_offset = {x = -5, y = 2, z = 8},
            view_offset = subways.use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "2",
            attach_offset = {x = 5, y = 2, z = 8},
            view_offset = subways.use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "3",
            attach_offset = {x = -5, y = 2, z = 0},
            view_offset = subways.use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "4",
            attach_offset = {x = 5, y = 2, z = 0},
            view_offset = subways.use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "5",
            attach_offset = {x = -5, y = 2, z = -8},
            view_offset = subways.use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "6",
            attach_offset = {x = 5, y = 2, z = -8},
            view_offset = subways.use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "7",
            attach_offset = {x = -5, y = 2, z = -25},
            view_offset = subways.use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
        {
            name = "8",
            attach_offset = {x = 5, y = 2, z = -25},
            view_offset = subways.use_attachment_patch and {x = 0, y = 0, z = 0} or {x = 0, y = 2, z = 0},
            group = "passenger",
        },
    },
}

-- Register this wagon with subways
subways.register_subway(subway_wagon_def)

-- Crafting recipes
minetest.register_craft({
    output = subway_wagon_def.mod_name..":hr4000",
    recipe = {
        {"default:steelblock", "default:steelblock", "default:steelblock"},
        {"xpanes:pane_flat", "dye:yellow", "xpanes:pane_flat"},
        {"advtrains:wheel", "dye:yellow", "advtrains:wheel"}
    }
})
