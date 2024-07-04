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
    mesh = "type_9_middle.b3d",
    textures = {"type_9_middle.png"},
    drives_on = {default = true},
    max_speed = 20,
    seats = {
        {
            name = "Passenger",
            attach_offset = {x = 0, y = 2, z = 0},
            view_offset = {x = 0, y = 2, z = 0},
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
    assign_to_seat_group = {"passenger"},
    is_locomotive = false,
    wagon_span = 1.015,
    collisionbox = {
        -1.0, -0.5, -1.0,
        1.0, 2.5, 1.0,
    },
}


advtrains.register_wagon("subways:lrv_type_9", train_def, "LRV Type 9", "type_9_inv.png")
advtrains.register_wagon("subways:lrv_type_9_middle", train_middle_def, "LRV Type 9 Middle Section", "type_9_inv.png")
