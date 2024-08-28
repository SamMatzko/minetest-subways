local train_def = {
    craft = {
        output = "subways_01700_series:01700_series",
        recipe = {
            {"default:steelblock", "default:steelblock", "default:steelblock"},
            {"xpanes:pane_flat", "dye:red", "xpanes:pane_flat"},
            {"advtrains:wheel", "", "advtrains:wheel"},
        },
    },
    displays = {
        {
            background_size = 100,
            display = "line",
            offset = {x = 0, y = -2},
            slot = 2,
        },
        {
            background_size = 100,
            display = "line",
            offset = {x = 0, y = 0},
            slot = 3,
        },
    },
    livery_def = {
        livery_template = {
            name = "01700 Series",
            designer = "Sam Matzko",
            texture_license = "CC-BY-SA-3.0",
            texture_creator = "Sam Matzko",
            notes = "Color overrides for exterior accents.",
            base_textures = {
                "01700_series.png",
            },
            overlays = {
                [1] = {name = "Exterior Accents", slot_idx = 1, texture = "01700_series_livery.png", alpha = 255},
            },
        },
        predefined_livery = {
            name = "Standard Red",
            notes = "The default red color scheme.",
            livery_design = {
                livery_template_name = "01700 Series",
                overlays = {
                    [1] = {id = 1, color = "#FF0000"},
                },
            },
        },
    },
    wagon_def = {
        mesh = "01700_series.b3d",
        textures = {
            "01700_series.png",
            "subways_displays.png",
            "subways_displays.png",
        },
        base_texture = "01700_series.png",
        base_texture_size = 400,
        light_texture_backwards = "01700_series_backwards.png",
        light_texture_forwards = "01700_series_forwards.png",
        light_texture_pos = {x = 224, y = 282},
        drives_on = {default = true},
        max_speed = 15,
        seats = {
            {
                name = "driver_stand",
                attach_offset = {x = -4, y = 3, z = 28},
                view_offset = {x = 0, y = 0, z = 0},
                group = "driver_stand",
            },
            {
                name = "1",
                attach_offset = {x = 4, y = 3, z = 0},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "2",
                attach_offset = {x = -4, y = 3, z = 0},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "3",
                attach_offset = {x = 4, y = 3, z = 7},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "4",
                attach_offset = {x = -4, y = 3, z = 7},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "5",
                attach_offset = {x = 4, y = 3, z = -7},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "6",
                attach_offset = {x = -4, y = 3, z = -7},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "7",
                attach_offset = {x = 4, y = 3, z = -29},
                view_offset = {x = 0, y = 0, z = 0},
                group = "passenger",
            },
            {
                name = "9",
                attach_offset = {x = -4, y = 3, z = -29},
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
        coupler_types_back = {tomlinson = true},
        coupler_types_front = {tomlinson = true},
        assign_to_seat_group = {"passenger", "driver_stand"},
        is_locomotive = true,
        wagon_span = 3.56,
        wheel_positions = {2, -2},
        collisionbox = {
            -1.0, -0.5, -1.0,
            1.0, 2.5, 1.0,
        },
    },
}

subways.register_subway("01700_series", train_def, "01700 Series", "01700_series_inv.png")

if advtrains.register_wagon_alias then
    advtrains.register_wagon_alias("red_subway_wagon", "01700_series")
end
