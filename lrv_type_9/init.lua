-- The coupler to join the main section to the middle section
advtrains.register_coupler_type("lrv_type_9", "LRV Type 9 Coupler")

local train_def = {
    mesh = "type_9.b3d",
    textures = {"type_9.png"},
    drives_on = {default = true},
    max_speed = 20,
    seats = {
        {
            name = "Driver Stand",
            attach_offset = {x = 0, y = 2, z = 0},
            view_offset = {x = 0, y = 2, z = 0},
            group = "driver_stand",
        },
        {
            name = "Passenger",
            attach_offset = {x = 0, y = 2, z = 0},
            view_offset = {x = 0, y = 2, z = 0},
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
    assign_to_seat_group = {"driver_stand", "passenger"},
    is_locomotive = true,
    wagon_span = 3.1,
    collisionbox = {
        -1.0, -0.5, -1.0,
        1.0, 2.5, 1.0,
    },
}

local train_middle_def = {
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

-- subways.register_subway("lrv_type_9", train_def, "LRV Type 9", "type_9_inv.png")
subways.register_subway("lrv_type_9_middle", train_middle_def, "LRV Type 9 Middle Section", "type_9_middle_inv.png")
