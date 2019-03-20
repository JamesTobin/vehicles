--nowar branch

-- Load support for intllib.
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

vehicles = {}

dofile(minetest.get_modpath("vehicles").."/api.lua")

--very laggy and buggy flight
-- minetest.register_globalstep(function(dtime)
	-- for _, player in ipairs(minetest.get_connected_players()) do
		-- local dir = player:get_look_dir();
		-- local pos = player:getpos();
		-- local ctrl = player:get_player_control();
		-- local pos1 = {x=pos.x+dir.x*1,y=pos.y+dir.y*1,z=pos.z+dir.z*1}
		-- if ctrl.up == true then
		-- player:moveto(pos1, false)
		-- else
		-- end
	-- end
-- end)

local step = 1.1

local enable_built_in = true


minetest.register_entity("vehicles:water", {
	visual = "sprite",
	textures = {"vehicles_trans.png"},
	velocity = 15,
	acceleration = -5,
	damage = 2,
	collisionbox = {0, 0, 0, 0, 0, 0},
	on_activate = function(self)
		self.object:setacceleration({x=0, y=-1, z=0})
	end,
	on_step = function(self, obj, pos)
		minetest.after(5, function()
			self.object:remove()
		end)
		local pos = self.object:getpos()
	minetest.add_particlespawner({
		amount = 1,
		time = 1,
		minpos = {x=pos.x, y=pos.y, z=pos.z},
		maxpos = {x=pos.x, y=pos.y, z=pos.z},
		minvel = {x=0, y=0, z=0},
		maxvel = {x=0, y=-0.2, z=0},
		minacc = {x=0, y=-1, z=0},
		maxacc = {x=0, y=-1, z=0},
		minexptime = 1,
		maxexptime = 1,
		minsize = 4,
		maxsize = 5,
		collisiondetection = false,
		vertical = false,
		texture = "vehicles_water.png",
	})
	local node = minetest.env:get_node(pos).name
	if node == "fire:basic_flame" then
	minetest.remove_node(pos)
	end
	end
})


minetest.register_entity("vehicles:ute2", {
	visual = "mesh",
	mesh = "ute.b3d",
	textures = {"vehicles_ute2.png"},
	velocity = 17,
	acceleration = -5,
	stepheight = 1.5,
	hp_max = 200,
	physical = true,
	collisionbox = {-1.4, 0, -1.4, 1.4, 1, 1.4},
	on_rightclick = function(self, clicker)
		if self.driver and clicker == self.driver then
		vehicles.object_detach(self, clicker, {x=1, y=0, z=1})
		elseif self.driver and clicker ~= self.driver and not self.rider then
		clicker:set_attach(self.object, clicker, {x=0, y=5, z=-5}, {x=0, y=0, z=0})
		self.rider = true
		elseif self.driver and clicker ~=self.driver and self.rider then
		clicker:set_detach()
		self.rider = false
		elseif not self.driver then
		vehicles.object_attach(self, clicker, {x=0, y=5, z=4}, false, {x=0, y=2, z=4})
		minetest.sound_play("engine_start", 
		{to_player=self.driver:get_player_name(), gain = 4, max_hear_distance = 3, loop = false})
		self.sound_ready = false
		minetest.after(14, function()
		self.sound_ready = true
		end)
		end
	end,
	on_punch = vehicles.on_punch,
	on_activate = function(self)
	self.nitro = true
	end,
	on_step = function(self, dtime)
		return vehicles.on_step(self, dtime, {
			speed = 17, 
			decell = 0.95,
			boost = true,
			boost_duration = 6,
			boost_effect = "vehicles_nitro.png",
			driving_sound = "engine",
			sound_duration = 11,
			brakes = true,
		})
	end,
})

vehicles.register_spawner("vehicles:ute2", S("Ute"), "vehicles_ute_inv.png")



minetest.register_entity("vehicles:lambogoni", {
	visual = "mesh",
	mesh = "lambogoni.b3d",
	textures = {"vehicles_lambogoni.png"},
	velocity = 19,
	acceleration = -5,
	stepheight = step,
	hp_max = 200,
	physical = true,
	collisionbox = {-1, 0, -1, 1.3, 1, 1},
	on_rightclick = function(self, clicker)
		if self.driver and clicker == self.driver then
		vehicles.object_detach(self, clicker, {x=1, y=0, z=1})
		elseif not self.driver then
		vehicles.object_attach(self, clicker, {x=0, y=5, z=4}, false, {x=0, y=2, z=4})
		minetest.sound_play("engine_start", 
		{to_player=self.driver:get_player_name(), gain = 4, max_hear_distance = 3, loop = false})
		self.sound_ready = false
		minetest.after(14, function()
		self.sound_ready = true
		end)
		end
	end,
	on_punch = vehicles.on_punch,
	on_activate = function(self)
		self.nitro = true
	end,
	on_step = function(self, dtime)
		return vehicles.on_step(self, dtime, {
			speed = 19, 
			decell = 0.99,
			boost = true,
			boost_duration = 4,
			boost_effect = "vehicles_nitro.png",
			driving_sound = "engine",
			sound_duration = 11,
			brakes = true,
		})
	end,
})

vehicles.register_spawner("vehicles:lambogoni", S("Lambogoni (grey)"), "vehicles_lambogoni_inv.png")
