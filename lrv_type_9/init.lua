-- Begin support code for AdvTrains Livery Designer

local use_advtrains_livery_designer = minetest.get_modpath( "advtrains_livery_designer" ) and advtrains_livery_designer
local mod_name = "subways_lrv_type_9"

local livery_templates = {
	["advtrains:lrv_type_9"] = {
		{
			name = "Basic Window Band",
			designer = "Marnack",
			texture_license = "CC-BY-SA-3.0",
			texture_creator = "Samuel Matzko",
			notes = "This template supports independent color overrides of the exterior accents, side doors and seats.",
			base_textures = {
				"type_9_wagon_exterior.png",
				"type_9_wagon_interior.png",
				"type_9_door.png",
				"type_9_seat.png"
			},
			overlays = {
				[1] = {name = "Exterior Accents",	slot_idx = 1,	texture = "type_9_livery.png"},
				[2] = {name = "Side Doors",			slot_idx = 3,	texture = "type_9_door_livery.png"},
				[3] = {name = "Seats",				slot_idx = 4,	texture = "type_9_seat_livery.png",		alpha = 248},
			},
		},
	},
}

local predefined_liveries = {
	{
		name = "Sea Green Special",
		notes = "",
		livery_design = {
			livery_template_name = "Basic Window Band",
			overlays = {
				[1] = {id = 1,	color = "#2E8B57"},	-- "Exterior Accents",
				[2] = {id = 2,	color = "#FFFFFF"},	-- "Side Doors",
				[3] = {id = 3,	color = "#2E8B57"},	-- "Seats",
			},
		},
	},
	{
		name = "Green Gazebo",
		notes = "",
		livery_design = {
			livery_template_name = "Basic Window Band",
			overlays = {
				[1] = {id = 1,	color = "#006400"},	-- "Exterior Accents",
				[2] = {id = 2,	color = "#008000"},	-- "Side Doors",
				[3] = {id = 3,	color = "#006400"},	-- "Seats",
			},
		},
	},
	{
		name = "Tan Caravan",
		notes = "",
		livery_design = {
			livery_template_name = "Basic Window Band",
			overlays = {
				[1] = {id = 1,	color = "#D2B48C"},	-- "Exterior Accents",
				[2] = {id = 2,	color = "#F5DEB3"},	-- "Side Doors",
				[3] = {id = 3,	color = "#B2793E"},	-- "Seats",
			},
		},
	},
}

if use_advtrains_livery_designer then
	-- This function is called by the advtrains_livery_designer tool whenever the player
	-- activates the "Apply" button.
	-- This implementation is specific to lrv_type_9. A more complex
	-- implementation may be needed if other wagons or livery templates are added.
	local function apply_wagon_livery_textures(player, wagon, textures)
		if wagon and textures and textures[1] then
			local data = advtrains.wagons[wagon.id]
			data.livery = textures[1]
			data.door = textures[3]
			data.seats = textures[4]
			wagon:set_textures(data)
		end
	end

	-- Register this mod and its livery function with the advtrains_livery_designer tool.
	advtrains_livery_designer.register_mod(mod_name, apply_wagon_livery_textures)

	-- Register this mod's wagons and livery templates.
	for wagon_type, wagon_livery_templates in pairs(livery_templates) do
		advtrains_livery_database.register_wagon(wagon_type, mod_name)
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
	for _, predefined_livery in ipairs(predefined_liveries) do
		local livery_design = predefined_livery.livery_design
		livery_design.wagon_type = "advtrains:lrv_type_9"
		advtrains_livery_database.add_predefined_livery(
			predefined_livery.name,
			livery_design,
			mod_name,
			predefined_livery.notes
		)
	end
end

local function update_livery(wagon, puncher)
	local itemstack = puncher:get_wielded_item()
	local item_name = itemstack:get_name()
	if use_advtrains_livery_designer and item_name == advtrains_livery_designer.tool_name then
		advtrains_livery_designer.activate_tool(puncher, wagon, mod_name)
		return true
	end
	return false
end

-- End of support code for AdvTrains Livery Designer

local function set_livery(self, puncher, itemstack, data)
	local meta = itemstack:get_meta()
	local color = meta:get_string("paint_color")
	local alpha = tonumber(meta:get_string("alpha"))
	if color and color:find("^#%x%x%x%x%x%x$") then
		data.livery = self.base_texture.."^("..self.base_livery.."^[colorize:"..color..":255)"
		data.door = self.door_texture.."^("..self.door_livery.."^[colorize:"..color..":255)"
		data.seats = self.seat_texture
		self:set_textures(data)
	end
end

local function set_textures(self, data)
	if data.livery then
		self.livery = data.livery
		self.door_livery_data = data.door
		self.seat_livery_data = data.seats
		self.object:set_properties({
				textures={data.livery, "type_9_wagon_interior.png", data.door, data.seats}
		})
	end
end

local use_attachment_patch = advtrains_attachment_offset_patch and advtrains_attachment_offset_patch.setup_advtrains_wagon

local subway_wagon_def = {
    mesh="type_9.b3d",
    textures={
		"type_9_wagon_exterior.png",
		"type_9_wagon_interior.png",
		"type_9_door.png",
		"type_9_seat.png",
	},
    base_texture = "type_9_wagon_exterior.png",
    base_livery = "type_9_livery.png",
	seat_texture = "type_9_seat.png",
	seat_livery = "type_9_seat_livery.png",
    door_texture = "type_9_door.png",
    door_livery = "type_9_door_livery.png",
	seat_texture = "type_9_seat.png",
    set_textures = set_textures,
    set_livery = set_livery,
	custom_may_destroy = function(wagon, puncher, time_from_last_punch, tool_capabilities, direction)
		return not update_livery(wagon, puncher)
	end,
    drives_on={default=true},
    max_speed=15,
    seats={
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
		{
			name="2",
			attach_offset={x=-4, y=0.5, z=8},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=0.5, z=0},
			group="passenger",
		},
		{
			name="3",
			attach_offset={x=-4, y=0.5, z=0},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=0.5, z=0},
			group="passenger",
		},
		{
			name="4",
			attach_offset={x=-4, y=0.5, z=-8},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=0.5, z=0},
			group="passenger",
		},
		{
			name="5",
			attach_offset={x=-4, y=0.5, z=-18},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=0.5, z=0},
			group="passenger",
		},
		{
			name="6",
			attach_offset={x=-4, y=0.5, z=-24},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=0.5, z=0},
			group="passenger",
		},
		{
			name="7",
			attach_offset={x=-4, y=0.5, z=8},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=0.5, z=0},
			group="passenger",
		},
		{
			name="8",
			attach_offset={x=-4, y=0.5, z=0},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=0.5, z=0},
			group="passenger",
		},
		{
			name="9",
			attach_offset={x=-4, y=0.5, z=-8},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=0.5, z=0},
			group="passenger",
		},
		{
			name="10",
			attach_offset={x=-4, y=0.5, z=-18},
			view_offset=use_attachment_patch and {x=0, y=0, z=0} or {x=0, y=0.5, z=0},
			group="passenger",
		},
		{
			name="11",
			attach_offset={x=-4, y=0.5, z=-24},
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
	drops={"default:steelblock 4"},
    visual_size={x=1, y=1},
	wagon_span=3,
	collisionbox = {
		-1.0, -0.5, -1.0,
		1.0, 2.5, 1.0
	},
	custom_on_step = function(self, dtime, data, train)
		-- Set the line number for the train
		local line = ""
		local line_number = tonumber(train.line)
		if line_number and line_number <= 9 and line_number > 0 then
			line = "^type_9_line_"..train.line..".png"
		end
		if self.livery then
			self.object:set_properties({
				textures={
					self.livery..line,
					"type_9_wagon_interior.png",
					"type_9_door.png^"..self.door_livery_data,
					"type_9_seat.png^"..(self.seat_livery_data or "")
				}
			})
		else
			self.object:set_properties({
				textures={
					"type_9_wagon_exterior.png"..line,
					"type_9_wagon_interior.png",
					"type_9_door.png",
					"type_9_seat.png"
				}
			})
		end
	end
}
if use_attachment_patch then
	advtrains_attachment_offset_patch.setup_advtrains_wagon(subway_wagon_def);
end
advtrains.register_wagon("lrv_type_9", subway_wagon_def, "LRV Type 9", "type_9_inv.png")

-- Craft recipes
minetest.register_craft({
	output="advtrains:lrv_type_9",
	recipe={
		{"default:steelblock", "default:steelblock", "default:steelblock"},
		{"xpanes:pane_flat", "dye:dark_green", "xpanes:pane_flat"},
		{"advtrains:wheel", "", "advtrains:wheel"}
	}
})
