advtrains.register_wagon("green_subway_wagon", {
    mesh="green_subway_wagon.b3d",
    textures={
		"green_subway_wagon.png",
		"green_subway_wagon_interior.png",
		"green_subway_wagon_door.png",
		"green_subway_wagon_seat.png",
		"green_subway_wagon_seat.png",
		"green_subway_wagon_seat.png",
		"green_subway_wagon_seat.png",
		"green_subway_wagon_seat.png",
		"green_subway_wagon_seat.png",
		"green_subway_wagon_seat.png",
		"green_subway_wagon_seat.png",
		"green_subway_wagon_seat.png",
		"green_subway_wagon_seat.png",
		"green_subway_wagon_seat.png",
		"green_subway_wagon_seat.png"
	},
    drives_on={default=true},
    max_speed=15,
    seats={
		{
			name="Driver stand",
			attach_offset={x=0, y=0, z=0},
			view_offset={x=0, y=0, z=0},
			group="driver_stand",
		},
        {
			name="1",
			attach_offset={x=-4, y=-2, z=8},
			view_offset={x=0, y=0, z=0},
			group="passenger",
		}
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
    assign_to_seat_group={"passenger", "driver_stand"},
    door_entry={-1, 1},
	doors={
		open={
			[-1]={frames={x=0, y=20}, time=1},
			[1]={frames={x=40, y=60}, time=1}
		},
		close={
			[-1]={frames={x=20, y=40}, time=1},
			[1]={frames={x=60, y=80}, time=1}
		}
	},
    is_locomotive=true,
    visual_size={x=1, y=1},
	wagon_span=3,
	collisionbox = {
		-1.0, -0.5, -1.0,
		1.0, 2.5, 1.0
	},
}, attrans("Green Subway Car"), "green_subway_wagon_inv.png")