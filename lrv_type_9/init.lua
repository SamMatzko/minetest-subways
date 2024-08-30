-- The coupler to join the main section to the middle section
advtrains.register_coupler_type("lrv_type_9", "LRV Type 9 Coupler")

local train_def = {
    craft = {
        output = "subways_lrv_type_9:lrv_type_9",
        recipe = {
            {"default:steelblock", "default:steelblock", "default:steelblock"},
            {"xpanes:pane_flat", "dye:dark_green", "xpanes:pane_flat"},
            {"advtrains:wheel", "", "advtrains:wheel"},
        },
    },
    displays = {
        {
            background_size = 140,
            display = "line",
            offset = {x = 16, y = 2},
            slot = 2,
        },
        {
            background_size = 140,
            display = "line",
            offset = {x = 0, y = 15},
            slot = 3,
        },
    },
    livery_def = {
        livery_template = {
            name = "LRV Type 9",
            designer = "Sam Matzko",
            texture_license = "CC-BY-SA-3.0",
            texture_creator = "Sam Matzko",
            notes = "Color override for exterior accents.",
            base_textures = {
                "type_9.png",
            },
            overlays = {
                [1] = {name = "Exterior Accents", slot_idx = 1, texture = "type_9_livery.png", alpha = 255},
            },
        },
        predefined_livery = {
            name = "Standard Green",
            notes = "The default green color scheme.",
            livery_design = {
                livery_template_name = "LRV Type 9",
                overlays = {
                    [1] = {id = 1, color = "#00782B"},
                },
            },
        },
    },
    wagon_def = {
        mesh = "type_9.b3d",
        textures = {
            "type_9.png",
            "subways_displays.png",
            "subways_displays.png",
        },
        base_texture = "type_9.png",
        base_texture_size = 470,
        light_texture_backwards = "type_9_backwards.png",
        light_texture_forwards = "type_9_forwards.png",
        light_texture_pos = {x = 242, y = 338},
        drives_on = {default = true},
        max_speed = 15,
        seats = {
            {
                name = "driver_stand",
                attach_offset = {x = -3.5, y = 0, z = 21},
                view_offset = {x = 0, y = 0, z = 0},
                group = "driver_stand",
            },
            {
                name = "1",
                attach_offset = {x = -3.7, y = 0, z = 13},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "2",
                attach_offset = {x = -3.7, y = 0, z = 6},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "3",
                attach_offset = {x = -3.7, y = 0, z = -1},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "4",
                attach_offset = {x = 3.7, y = 0, z = 6},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "5",
                attach_offset = {x = 3.7, y = 0, z = -1},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "6",
                attach_offset = {x = -3.7, y = 0, z = -24},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "7",
                attach_offset = {x = 3.7, y = 0, z = -24},
                view_offset = {x = 0, y = 0, z = 0},
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
                driving_ctrl_access = false,
            },
        },
        coupler_types_back = {lrv_type_9 = true},
        coupler_types_front = {tomlinson = true},
        assign_to_seat_group = {"passenger", "driver_stand"},
        is_locomotive = true,
        wagon_span = 3.1,
        wheel_positions = {0.5, -3.1},
        collisionbox = {
            -1.0, -0.5, -1.0,
            1.0, 2.5, 1.0,
        },
    },
}

local train_middle_def = {
    craft = {
        output = "subways_lrv_type_9_middle:lrv_type_9_middle",
        recipe = {
            {"default:steelblock", "", "default:steelblock"},
            {"xpanes:pane_flat", "dye:dark_green", "xpanes:pane_flat"},
            {"advtrains:wheel", "", "advtrains:wheel"},
        },
    },
    livery_def = {
        livery_template = {
            name = "LRV Type 9 Middle Section",
            designer = "Sam Matzko",
            texture_license = "CC-BY-SA-3.0",
            texture_creator = "Sam Matzko",
            notes = "Color override for exterior accents.",
            base_textures = {
                "type_9_middle.png",
            },
            overlays = {
                [1] = {name = "Exterior Accents", slot_idx = 1, texture = "type_9_middle_livery.png", alpha = 255},
            },
        },
        predefined_livery = {
            name = "Standard Green",
            notes = "The default green color scheme.",
            livery_design = {
                livery_template_name = "LRV Type 9 Middle Section",
                overlays = {
                    [1] = {id = 1, color = "#00782B"},
                },
            },
        },
    },
    wagon_def = {
        mesh = "type_9_middle.b3d",
        textures = {"type_9_middle.png"},
        base_texture = "type_9_middle.png",
        max_speed = 15,
        seats = {
            {
                name = "1",
                attach_offset = {x = 3, y = 0, z = 4},
                view_offset = {x = 0, y = 0, z = 0}, -- This is the same regardless of the attchment patch.
                group = "passenger",
            },
            {
                name = "2",
                attach_offset = {x = -3, y = 0, z = 4},
                view_offset = {x = 0, y = 0, z = 0}, -- This is the same regardless of the attchment patch.
                group = "passenger",
            },
            {
                name = "3",
                attach_offset = {x = 3, y = 0, z = -4},
                view_offset = {x = 0, y = 0, z = 0}, -- This is the same regardless of the attchment patch.
                group = "passenger",
            },
            {
                name = "4",
                attach_offset = {x = -3, y = 0, z = -4},
                view_offset = {x = 0, y = 0, z = 0}, -- This is the same regardless of the attchment patch.
                group = "passenger",
            },
        },
        seat_groups = {
            passenger = {
                name = "Passenger",
                access_to = {},
                require_doors_open = true,
                driving_ctrl_access = false,
            },
        },
        coupler_types_back = {lrv_type_9 = true},
        coupler_types_front = {lrv_type_9 = true},
        assign_to_seat_group = {"passenger"},
        is_locomotive = false,
        wagon_span = 1.015,
        wheel_positions = {-0.6, 0.6},
        collisionbox = {
            -1.0, -0.5, -0.7,
            1.0, 2.5, 0.7,
        },
    },
}

subways.register_subway("lrv_type_9", train_def, "LRV Type 9", "type_9_inv.png")
subways.register_subway("lrv_type_9_middle", train_middle_def, "LRV Type 9 Middle Section", "type_9_middle_inv.png")

if advtrains.register_wagon_alias then
    advtrains.register_wagon_alias("advtrains:green_subway_wagon", "subways_lrv_type_9:lrv_type_9")
end
