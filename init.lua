local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

-- Translation setup using intllib
local S = core.get_translator(modname)

-- Remove /reload command as it's not reliable
-- Delay loading mod.lua until player joins to ensure player object and world are ready
local function load_mod()
  local ok, err = pcall(dofile, modpath .. '/mod.lua')
  if not ok then
    core.log('error', '[reload_mod] ' .. S('Error in mod.lua: @1', tostring(err)))
  end
end

core.register_on_joinplayer(function(player)
  if player:get_player_name() == 'singleplayer' then
    load_mod()
  end
end)
