mod = {}

-- Translation setup
local modname = core.get_current_modname()
local S = core.get_translator(modname)

-- Helper functions (language-independent)
function each(list)
  local i = 0
  return function()
    i = i + 1
    return list[i]
  end
end

math.randomseed(os.time())
function random(min, max)
  if type(min) == 'table' then
    return min[math.random(1, #min)]
  end
  if not min or not max then
    return math.random()
  end
  if min > max then
    min, max = max, min
  end
  return math.random(min, max)
end

function wait(seconds, callback)
  core.after(seconds, callback)
end

-- Base API with English function names
function mod.position(x, y, z)
  return vector.new(x, y, z)
end

-----------------------------------
-------------- Chat ---------------
-----------------------------------
function mod.chat(message)
  if type(message) ~= 'string' then
    message = dump(message)
  end
  core.chat_send_all(message)
end

function mod.new_command(name, callback)
  core.register_chatcommand(name, {
    func = function(_, param)
      local answer = callback(param)
      if answer then
        return true, answer
      end
      return true
    end,
  })
end

-----------------------------------
---------- World editing ----------
-----------------------------------
function mod.read_block(pos)
  return core.get_node(pos).name
end

function mod.set_block(block_name, pos)
  core.set_node(pos, { name = block_name })
end

function mod.set_area(block_name, pos, pos2)
  local min_x, max_x = math.min(pos.x, pos2.x), math.max(pos.x, pos2.x)
  local min_y, max_y = math.min(pos.y, pos2.y), math.max(pos.y, pos2.y)
  local min_z, max_z = math.min(pos.z, pos2.z), math.max(pos.z, pos2.z)
  for ix = min_x, max_x do
    for iy = min_y, max_y do
      for iz = min_z, max_z do
        core.set_node({ x = ix, y = iy, z = iz }, { name = block_name })
      end
    end
  end
end

function mod.cube(block_name, pos, size)
  local half = math.floor(size / 2)
  local pos1 = { x = pos.x - half, y = pos.y - half, z = pos.z - half }
  local pos2 = { x = pos.x + half, y = pos.y + half, z = pos.z + half }
  mod.set_area(block_name, pos1, pos2)
end

function mod.sphere(block_name, pos, radius)
  local radius_squared = radius * radius
  for ix = -radius, radius do
    for iy = -radius, radius do
      for iz = -radius, radius do
        if ix * ix + iy * iy + iz * iz <= radius_squared then
          core.set_node(pos:add { x = ix, y = iy, z = iz }, { name = block_name })
        end
      end
    end
  end
end

function mod.remove_block(pos)
  core.remove_node(pos)
end

function mod.remove_area(pos, pos2)
  core.delete_area(pos, pos2)
end

function mod.find_block(pos, distance, block_name)
  if type(block_name) == 'string' then
    block_name = { block_name }
  end
  return core.find_node_near(pos, distance, block_name)
end

function mod.find_blocks(pos, distance, block_name)
  if type(block_name) == 'string' then
    block_name = { block_name }
  end
  local pos1 = pos:subtract { x = distance, y = distance, z = distance }
  local pos2 = pos:add { x = distance, y = distance, z = distance }
  local found_nodes = core.find_nodes_in_area(pos1, pos2, block_name)
  local filtered_nodes = {}
  for _, node in ipairs(found_nodes) do
    local delta = node:subtract(pos)
    if delta.x * delta.x + delta.y * delta.y + delta.z * delta.z <= distance * distance then
      table.insert(filtered_nodes, node)
    end
  end
  return filtered_nodes
end

-----------------------------------
-------- Tree Wrapper ------------
-----------------------------------
function mod.tree(pos, type)
  -- stylua: ignore
  local generators = {
    tree          = function(p) default.grow_tree(p, false) end,
    apple         = default.grow_new_apple_tree,
    jungle        = default.grow_new_jungle_tree,
    emergent      = default.grow_new_emergent_jungle_tree,
    pine          = default.grow_new_pine_tree,
    snow_pine     = default.grow_new_snowy_pine_tree,
    acacia        = default.grow_new_acacia_tree,
    aspen         = default.grow_new_aspen_tree,
    bush          = default.grow_bush,
    blueberry     = default.grow_blueberry_bush,
    large_cactus  = default.grow_large_cactus,
  }
  local tree_generator
  -- stylua: ignore
  if type == nil then tree_generator = generators.tree
  else tree_generator = generators[type:lower()] end
  if not tree_generator then
    mod.chat(S("Tree type '@1' unknown!", type))
    return
  end
  tree_generator(pos)
end

-----------------------------------
------ Player and Physics --------
-----------------------------------
function mod.player()
  return core.get_player_by_name 'singleplayer'
end

function mod.player_pos()
  return mod.player():get_pos()
end

function mod.rel_pos(distance)
  local player = mod.player()
  local player_pos = player:get_pos()
  local look_dir = player:get_look_dir()
  local target_pos = vector.new(
    player_pos.x + look_dir.x * distance,
    player_pos.y + look_dir.y * distance + 1,
    player_pos.z + look_dir.z * distance
  )
  return target_pos
end

function mod.infront(distance)
  return mod.rel_pos(distance)
end

function mod.infront(distance)
  return mod.rel_pos(distance)
end

function mod.teleport_player(pos)
  local player = mod.player()
  player:set_pos(pos)
end

function mod.set_gravity(gravity)
  mod.player():set_physics_override {
    gravity = gravity,
  }
end

function mod.set_jump_strength(jump_strength)
  mod.player():set_physics_override {
    jump = jump_strength,
  }
end

function mod.set_speed(speed)
  mod.player():set_physics_override {
    speed = speed,
  }
end

-----------------------------------
------ New Items and Blocks ------
-----------------------------------
function mod.new_item(item_name, texture, callbacks)
  local item_id = 'coderdojo:' .. item_name:lower():gsub(' ', '_')
  local opts = {
    description = item_name,
    inventory_image = texture,
  }
  if callbacks and callbacks.place then
    opts.on_place = function(itemstack, placer, pointed_thing)
      if pointed_thing.type ~= 'node' then
        return itemstack
      end
      local remove_item = callbacks.place(pointed_thing.above, pointed_thing.under, placer)
      if remove_item then
        itemstack:take_item()
      end
      return itemstack
    end
  end
  if callbacks and callbacks.left_click then
    opts.on_use = function(itemstack, user, pointed_thing)
      if pointed_thing.type ~= 'node' then
        return itemstack
      end
      callbacks.left_click(pointed_thing.under, user)
      return itemstack
    end
  end
  if callbacks and callbacks.right_click then
    opts.on_secondary_use = function(itemstack, user, _)
      callbacks.right_click(user)
      return itemstack
    end
  end
  core.register_craftitem(item_id, opts)
end

function mod.new_block(block_name, texture, callbacks, one_sided_texture)
  local block_id = 'coderdojo:' .. block_name:lower():gsub(' ', '_')
  local opts = {
    description = block_name,
    tiles = {
      texture .. '^[sheet:6x1:1,0]', -- Top
      texture .. '^[sheet:6x1:0,0]', -- Bottom
      texture .. '^[sheet:6x1:4,0]', -- Right
      texture .. '^[sheet:6x1:5,0]', -- Left
      texture .. '^[sheet:6x1:2,0]', -- Back
      texture .. '^[sheet:6x1:3,0]', -- Front
    },
    paramtype2 = 'facedir',
    on_place = core.rotate_node,
    groups = { cracky = 3 },
  }
  if callbacks and callbacks.right_click then
    opts.on_rightclick = function(pos, _, _, pointed_thing)
      if pointed_thing == nil then
        return
      end
      callbacks.right_click(pos)
    end
  end
  if callbacks and callbacks.left_click then
    opts.on_punch = function(pos, _, puncher, pointed_thing)
      if pointed_thing == nil then
        return
      end
      callbacks.left_click(pos, puncher)
    end
  end
  if callbacks and callbacks.break_block then
    opts.on_dig = function(pos, node, digger)
      callbacks.break_block(pos, digger)
      core.node_dig(pos, node, digger)
    end
  end
  if one_sided_texture then
    opts.tiles = { texture }
  end
  core.register_node(block_id, opts)
end

-----------------------------------
------------ XBows API ------------
-----------------------------------
function mod.arrow(callback)
  if not XBows or type(XBows.registered_arrows) ~= 'table' then
    core.log('warning', '[dojo] ' .. S('XBows not found – arrow_pos disabled.'))
    return
  end
  for _, arrow_def in pairs(XBows.registered_arrows) do
    local old_hit = arrow_def.custom.on_hit_node
    arrow_def.custom.on_hit_node = function(selfObj, pointed_thing)
      if pointed_thing.under then
        callback(pointed_thing.under)
      end
      if old_hit then
        old_hit(selfObj, pointed_thing)
      end
    end
  end
end

-----------------------------------
-------- Particle effects ---------
-----------------------------------
function mod.particles(pos, texture, amount, range)
  range = range or 1
  core.add_particlespawner {
    amount = amount,
    time = 0.5,
    minpos = pos:subtract { x = range, y = range, z = range },
    maxpos = pos:add { x = range, y = range, z = range },
    minvel = { x = 0, y = 0, z = 0 },
    maxvel = { x = 1, y = 1, z = 1 },
    minacc = { x = 0, y = 0, z = 0 },
    maxacc = { x = 2, y = 2, z = 2 },
    minexptime = 1,
    maxexptime = 2,
    minsize = 1,
    maxsize = 2,
    collisiondetection = true,
    texture = texture,
  }
end

-----------------------------------
------- Projectile Wrapper -------
-----------------------------------
function mod.shoot_projectile(particle_texture, callback, delay, range)
  delay = delay or 0.1
  range = range or 100
  local player = mod.player()
  local ppos = player:get_pos()
  local dir = player:get_look_dir()
  local step_dist = 1
  local function step(i)
    local x = math.floor(ppos.x + dir.x * i + 0.5)
    local y = math.floor(ppos.y + 1 + dir.y * i + 0.5)
    local z = math.floor(ppos.z + dir.z * i + 0.5)
    local pos = vector.new(x, y, z)
    mod.particles(pos, particle_texture, 20)
    local node = core.get_node(pos).name
    if node ~= 'air' and node ~= 'default:air' then
      callback(pos)
      return
    end
    if i + step_dist <= range then
      core.after(delay, function()
        step(i + step_dist)
      end)
    end
  end
  step(1)
end

------------------------------------
---------- Global Timer ------------
------------------------------------
function mod.repeat_every(interval, callback)
  if type(interval) ~= 'number' or interval <= 0 then
    core.log('error', '[dojo] ' .. S('Invalid interval for mod.timer: @1', tostring(interval)))
    return
  end
  local time_elapsed = 0
  core.register_globalstep(function(deltatime)
    time_elapsed = time_elapsed + deltatime
    if time_elapsed >= interval then
      callback()
      time_elapsed = 0
    end
  end)
end

mod.repeat_every(10, function()
  core.set_timeofday(0.25)
end)

-- Move all aliases to mod table and use a table for extensibility
local aliases = {
  de = {
    zufall = random,
    warte = wait,
    lese_block = mod.read_block,
    setze_block = mod.set_block,
    setze_bereich = mod.set_area,
    wuerfel = mod.cube,
    kugel = mod.sphere,
    entferne_block = mod.remove_block,
    entferne_bereich = mod.remove_area,
    finde_block = mod.find_block,
    finde_bloecke = mod.find_blocks,
    baum = mod.tree,
    spieler = mod.player,
    spieler_pos = mod.player_pos,
    rel_pos = mod.rel_pos,
    teleportiere_spieler = mod.teleport_player,
    setze_schwerkraft = mod.set_gravity,
    setze_sprungkraft = mod.set_jump_strength,
    setze_geschwindigkeit = mod.set_speed,
    neues_item = mod.new_item,
    neuer_block = mod.new_block,
    pfeil = mod.arrow,
    partikel = mod.particles,
    schiesse_projektil = mod.shoot_projectile,
    wiederhole_alle = mod.repeat_every,
    neuer_befehl = mod.new_command,
    -- Add more if needed, e.g. chat = mod.chat as nachricht if desired
  }
}

local language = core.settings:get("language") or "en"
if aliases[language] then
  for alias, func in pairs(aliases[language]) do
    mod[alias] = func
  end
end