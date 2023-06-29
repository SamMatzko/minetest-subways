-- Optional supported mods
local use_attachment_patch = advtrains_attachment_offset_patch and advtrains_attachment_offset_patch.setup_advtrains_wagon
local use_advtrains_livery_designer = minetest.get_modpath("advtrains_livery_designer") and advtrains_livery_designer

-- Add optional support for the bike painter, in case users don't want to use the livery designer
local function set_livery(self, puncher, itemstack, data)
	local meta = itemstack:get_meta()
	local color = meta:get_string("paint_color")
	local alpha = tonumber(meta:get_string("alpha"))
	if color and color:find("^#%x%x%x%x%x%x$") then
		data.livery = self.base_texture.."^("..self.base_livery.."^[colorize:"..color..":255)"
		self:set_textures(data)
	end
end

-- The name of the mod used in registering for advtrains_livery_designer
local mod_name = "subways_6000_series_wagon"

-- The template definitions for 6000_series_locomotive and 6000_series_wagon
local livery_template_definition = {
	name = "6000-series",
	designer = "Sylvester Kruin",
	texture_license = "CC-BY-SA-3.0",
	texture_creator = "Sylvester Kruin",
	notes = "This template supports independent color overrides for the exterior accents.",
	base_textures = {
		"6000_coupler.png",
		"6000_cube.png",
		"6000_doors.png",
		"6000_seat.png",
		"6000_undercarriage.png",
		"6000_wagon_exterior.png",
		"6000_wagon_interior.png",
		"6000_wheels.png",
	},
	overlays = {
		[1] = {name = "Window Stripe", slot_idx = 6, texture = "6000_wagon_exterior_overlay.png", alpha = 255},
		[2] = {name = "Door Livery",   slot_idx = 3, texture = "6000_doors_overlay.png",          alpha = 255},
		[3] = {name = "Seat Color",    slot_idx = 4, texture = "6000_seat_overlay.png",           alpha = 240},
		[4] = {name = "Carpet Color",  slot_idx = 7, texture = "6000_wagon_interior_overlay.png", alpha = 240},
	},
}
-- Since the livery template definitions for locomotive and wagon are identical, just
-- use a variable
local livery_templates = {
	["advtrains:6000_series_locomotive"] = {
		livery_template_definition
	},
	["advtrains:6000_series_wagon"] = {
		livery_template_definition
	}
}

-- Predefined liveries
local predefined_livery_definition = {
	name = "Classic Brown",
	notes = "A classic brown livery",
	livery_design = {
		livery_template_name = "6000-series",
		overlays = {
			[1] = {id = 1, color = "#7D5343"},
			[2] = {id = 2, color = "#FFFFFF"},
			[3] = {id = 3, color = "#970000"},
			[4] = {id = 4, color = "#933415"}
		}
	}
}
-- Same thing here; the predefined liveries for locomotive and wagon are identical,
-- so we just use a variable
local predefined_liveries = {
	["advtrains:6000_series_locomotive"] = predefined_livery_definition,
	["advtrains:6000_series_wagon"] = predefined_livery_definition,
}

-- If advtrains_livery_designer is installed, setup and register the locomotive and wagon
if use_advtrains_livery_designer then

	-- This function is called by the advtrains_livery_designer tool whenever the player
	-- activates the "Apply" button.
	local function apply_wagon_livery_textures(player, wagon, textures)
		if wagon and textures and textures[1] then
			local data = advtrains.wagons[wagon.id]
			data.livery = textures[6]
			data.door = textures[3]
			data.seats = textures[4]
			data.floor = textures[7]
			wagon:set_textures(data)
		end
	end

	-- Register this mod and its livery function with the advtrains_livery_designer tool
	advtrains_livery_designer.register_mod(mod_name, apply_wagon_livery_textures)

	-- Register this mod's wagons and livery templates.
	for wagon_type, wagon_livery_templates in pairs(livery_templates) do

		-- Register this particular wagon with the mod name
		advtrains_livery_database.register_wagon(wagon_type, mod_name)

		-- Loop through the template definitions and add the templates and 
		-- template overlays for this wagon
		for _, livery_template in ipairs(wagon_livery_templates) do
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
		end
	end

	-- Register this mod's predefined wagon liveries.
	for wagon_type, predefined_livery in pairs(predefined_liveries) do
		local livery_design = predefined_livery.livery_design
		livery_design.wagon_type = wagon_type
		advtrains_livery_database.add_predefined_livery(
			predefined_livery.name,
			livery_design,
			mod_name,
			predefined_livery.notes
		)
	end
end

-- This function updates the livery when the train is punched
local function update_livery(wagon, puncher)
	local itemstack = puncher:get_wielded_item()
	local item_name = itemstack:get_name()
	if use_advtrains_livery_designer and item_name == advtrains_livery_designer.tool_name then
		advtrains_livery_designer.activate_tool(puncher, wagon, mod_name)
		return true
	end
	return false
end

-- This function is called by apply_wagon_livery_textures; it uses the data given
-- to set the wagons' textures
local function set_textures(self, data)
	if data.livery then
		self.livery = data.livery
		self.door_livery_data = data.door
		self.seat_livery_data = data.seats
		self.floor_livery_data = data.floor
		self.object:set_properties({
			textures={
				"6000_coupler.png",
				"6000_cube.png",
				data.door,
				data.seats,
				"6000_undercarriage.png",
				data.livery,
				data.floor,
				"6000_wheels.png",
			}
		})
	end
end

-- Variables used in the wagon definitions

-- The image textures for the wagons
local textures = {
	"6000_coupler.png",
	"6000_cube.png",
	"6000_doors.png",
	"6000_seat.png",
	"6000_undercarriage.png",
	"6000_wagon_exterior.png",
	"6000_wagon_interior.png",
	"6000_wheels.png",
}

-- Texture variables used for bike painter support
local base_texture = "6000_wagon_exterior.png"
local base_livery = "6000_wagon_exterior_overlay.png"

-- This function checks if the train is being punched by the livery tool and, if so, activates it
local custom_may_destroy = function(wagon, puncher, time_from_last_punch, tool_capabilities, direction)
	return not update_livery(wagon, puncher)
end

-- This function is used every time the wagon is updated, and controls the line numbers
-- and maintains the textures that have been set
local custom_on_step = function(self, dtime, data, train)
	-- Set the line number for the train
	local line = ""
	local line_number = tonumber(train.line)
	if line_number and line_number <= 9 and line_number > 0 then
		line = "^6000_line_"..train.line..".png"
	end
	if self.livery then
		self.object:set_properties({
			textures={
				"6000_coupler.png",
				"6000_cube.png",
				self.door_livery_data,
				self.seat_livery_data,
				"6000_undercarriage.png",
				self.livery..line,
				self.floor_livery_data,
				"6000_wheels.png",
			}
		})
	else
		self.object:set_properties({
			textures={
				"6000_coupler.png",
				"6000_cube.png",
				"6000_doors.png",
				"6000_seat.png",
				"6000_undercarriage.png",
				"6000_wagon_exterior.png"..line,
				"6000_wagon_interior.png",
				"6000_wheels.png",
			},
		})
	end
end

-- The start and end frames for the door animations
local doors = {
	open={
		[-1]={frames={x=0, y=20}, time=1},
		[1]={frames={x=40, y=60}, time=1}
	},
	close={
		[-1]={frames={x=20, y=40}, time=1},
		[1]={frames={x=60, y=80}, time=1}
	}
}

-- The collision box
local collisionbox = {
	-1.0, -0.5, -1.0,
	1.0, 2.5, 1.0
}

-- The coupler type used by the wagons
local coupler_type = {Tomlinson=true}

-- The positions for the wheels (doesn't work with the ContentDB version of Advtrains)
local wheel_positions = {2.1, -2.1}

-- The definition for 6000_series_locomotive
local subway_locomotive_def = {
    mesh="6000_series_locomotive.b3d",
	base_texture = base_texture,
	base_livery = base_livery,
    textures = textures,
	set_textures = set_textures,
	set_livery = set_livery, -- This is for bike painter support
    drives_on={default=true},
    max_speed=15,
	custom_may_destroy = custom_may_destroy,
	custom_on_step = custom_on_step,
    seats={
		{
			name="Driver stand",
			attach_offset={x=-4, y=3.5, z=26},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="driver_stand",
		},
		-- Left side seats
        {
			name="1",
			attach_offset={x=-4, y=3.5, z=4},-- 4
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="2",
			attach_offset={x=-4, y=3.5, z=10},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="3",
			attach_offset={x=-4, y=3.5, z=-4},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="4",
			attach_offset={x=-4, y=3.5, z=-10},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="5",
			attach_offset={x=-4, y=3.5, z=-28},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		-- Right side seats
		{
			name="6",
			attach_offset={x=4, y=3.5, z=4},-- 4
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="7",
			attach_offset={x=4, y=3.5, z=10},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="8",
			attach_offset={x=4, y=3.5, z=-4},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="9",
			attach_offset={x=4, y=3.5, z=-10},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="10",
			attach_offset={x=4, y=3.5, z=-28},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
    },
    seat_groups = {
		driver_stand = {
			name = "Driver Stand",
			access_to = {"passenger"},
			require_doors_open=true,
			driving_ctrl_access=true,
		},
        passenger = {
			name = "Passenger Area",
			access_to = {"driver_stand"},
			require_doors_open=true,
		},
	},
    assign_to_seat_group = {"passenger", "driver_stand"},
    door_entry = {-1, 1},
	doors = doors,
    is_locomotive = true,
	drops = {"default:steelblock 4"},
    visual_size = {x=1, y=1},
	wagon_span = 3.45,
	wheel_positions = wheel_positions,
	collisionbox = collisionbox,
	coupler_types_front = coupler_type,
	coupler_types_back = coupler_type
}

-- The definition for 6000_series_wagon
local subway_wagon_def = {
    mesh="6000_series_wagon.b3d",
	base_livery = base_livery,
	base_texture = base_texture,
    textures = textures,
	set_textures = set_textures,
	set_livery = set_livery, -- This is for bike painter support
    drives_on={default=true},
    max_speed=15,
	custom_may_destroy = custom_may_destroy,
	custom_on_step = custom_on_step,
    seats={
		-- Left side seats
		{
			name="1",
			attach_offset={x=-4, y=3.5, z=28},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="2",
			attach_offset={x=-4, y=3.5, z=10},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="3",
			attach_offset={x=-4, y=3.5, z=4},-- 4
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="4",
			attach_offset={x=-4, y=3.5, z=-4},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="5",
			attach_offset={x=-4, y=3.5, z=-10},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="6",
			attach_offset={x=-4, y=3.5, z=-28},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		-- Right side seats
		{
			name="7",
			attach_offset={x=-4, y=3.5, z=28},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="8",
			attach_offset={x=-4, y=3.5, z=10},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="9",
			attach_offset={x=-4, y=3.5, z=4},-- 4
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="10",
			attach_offset={x=-4, y=3.5, z=-4},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="11",
			attach_offset={x=-4, y=3.5, z=-10},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
		{
			name="12",
			attach_offset={x=-4, y=3.5, z=-28},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=3.5, z=0},
			group="passenger",
		},
    },
    seat_groups = {
        passenger = {
			name = "Passenger Area",
			access_to = {},
			require_doors_open=true,
		},
	},
    assign_to_seat_group = {"passenger"},
    door_entry = {-1, 1},
	doors=doors,
    is_locomotive = false,
	drops = {"default:steelblock 4"},
    visual_size = {x=1, y=1},
	wagon_span = 3.45,
	wheel_positions = wheel_positions,
	collisionbox = collisionbox,
	coupler_types_front = coupler_type,
	coupler_types_back = coupler_type
}

-- Enable support for advtrains_attachment_offset_patch
if use_attachment_patch then
	advtrains_attachment_offset_patch.setup_advtrains_wagon(subway_locomotive_def)
	advtrains_attachment_offset_patch.setup_advtrains_wagon(subway_wagon_def)
end

-- Register the wagon and locomotive
advtrains.register_wagon("6000_series_locomotive", subway_locomotive_def, "6000-series Locomotive (Subways)", "6000_inv_locomotive.png")
advtrains.register_wagon("6000_series_wagon", subway_wagon_def, "6000-series Car (Subways)", "6000_inv_wagon.png")

-- Craft recipes
minetest.register_craft({
	output="advtrains:6000_series_wagon",
	recipe={
		{"default:steelblock", "default:steelblock", "default:steelblock"},
		{"xpanes:pane_flat", "dye:brown", "xpanes:pane_flat"},
		{"advtrains:wheel", "", "advtrains:wheel"}
	}
})
minetest.register_craft({
	output="advtrains:6000_series_locomotive",
	recipe={
		{"", "", ""},
		{"default:steelblock", "advtrains:6000_series_wagon", "default:steelblock"},
		{"", "", ""},
	}
})
