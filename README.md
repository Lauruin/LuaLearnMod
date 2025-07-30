# CoderDojo Minetest: Your Cheat Sheet

## 🚀 Welcome to your first Lua programming mod!

This mod was specifically designed to make programming in Lua with Luanti (Minetest) as easy as possible! Instead of overwhelming you with complicated APIs and technical details, this mod provides a simplified, beginner-friendly interface. So you can get started right away and bring your creative ideas to life in the Luanti world!

## 🌍 Language Support

This mod supports multiple languages! The interface will automatically adapt to your Luanti language settings:
- **English**: Default language with all functions in English
- **German (Deutsch)**: Available with German error messages and descriptions
- **Other languages**: Use English as fallback

To change your language, go to Luanti Settings → Advanced Settings → language

## 📝 How to use this mod:

1. **Open IDE**: You need a development environment (IDE). You can either:
   - **In Browser**: Go to [vscode.dev](https://vscode.dev) (works with Chrome, Edge and other Chromium-based browsers)
   - **Desktop Version**: Install VSCode or another Lua IDE on your computer

2. **Open Folder**: Open the mod folder in your IDE:
   ```
   /user/minetest/mods/LuaLearnMod/
   ```

3. **Programming**: Edit the file `mod.lua` - this is where you write your code!

4. **Apply Changes**: To see your changes in the game:
   - Save the `mod.lua` file in your IDE
   - Exit to the main menu in Luanti
   - Reload/rejoin your world
   - Your new code will now be active!

5. **Find Help**: This README is your cheat sheet - here you'll find all important commands and examples!

---

With this cheat sheet you'll learn how to change your own Minetest world with code!

First, here are the most important keys you'll need in Luanti:

- Move: W, A, S, D (forward, left, backward, right)
- Flight mode On/Off: K
- Open inventory: I
- Pause menu: ESC
- Commands: With `/`, important ones are for example `/time 6000` to set time to day `/sethome` to set home, `/home` to teleport home

## The basics of Lua
- Open inventory: I
- Pause menu: ESC
- Commands: With `/`, important ones are for example `/time 6000` to set time to day `/sethome` to set home, `/home` to teleport home

## The basics of Lua

Before we start, here are some very important things:

- **Commands:** Every command you give Minetest starts with `mod.`. For example `mod.chat("Hello")`.

- **Variables:** Think of a variable like a box where you can store something, for example text or a number.

  ```lua
  -- In the box 'greeting' we put the text "Hello World"
  local greeting = "Hello World!"
  -- Now we can use the box to send the greeting to chat
  mod.chat(greeting)
  ```

- **Positions:** To tell Minetest _where_ something should happen, we need coordinates (x, y, z).

  - **x:** left or right (East/West)
  - **y:** up or down
  - **z:** forward or backward (North/South)
    We write it like this: `mod.position(10, 5, 20)`

- **Decisions with `if`:** Sometimes your code should only do something _if_ a certain condition is true. Like a decision at a fork in the road.

  ```lua
  -- Check if the player is very high in the air
  if mod.player_pos().y > 50 then
    mod.chat("Watch out, you're falling deep!")
  else
    mod.chat("Everything safe down here.")
  end
  ```

- **Repetitions with `for`:** A `for` loop is great for repeating an action multiple times without having to rewrite the code over and over.

  - **Count from-to:** Tell the computer how many times to do something.
    ```lua
    -- Builds a small staircase of 5 stone steps upward
    for i = 1, 5 do
      mod.set_block("default:cobble", mod.position(i, i, 0))
    end
    ```

## Chat & Communication

**`mod.chat(message)`**

- **What it does:** Writes a message in the chat that everyone can see.
- **What you need:**
  - `message`: The text you want to send.
- **Example:**
  ```lua
  mod.chat("Hello everyone!")
  ```

**`mod.new_command(name, function)`**

- **What it does:** Creates a new chat command that players can use with `/name`.
- **What you need:**
  - `name`: The name of the command (without `/`).
  - `function`: The code that should run when someone uses the command.
- **Example:**
  ```lua
  -- Creates the command /party
  mod.new_command("party", function()
    mod.chat("🎉 Party time! 🎉")
    mod.particles(mod.player_pos(), "heart.png", 100, 5)
  end)
  ```

---

## Building & Changing the World

**`mod.set_block(block_name, position)`**

- **What it does:** Places a specific block at a specific location.
- **What you need:**
  - `block_name`: The name of the block (e.g., `"default:stone"`).
  - `position`: Where the block should be placed.
- **Example:**
  ```lua
  -- Places a diamond block 10 blocks above the player
  local player_pos = mod.player_pos()
  local above_player = mod.position(player_pos.x, player_pos.y + 10, player_pos.z)
  mod.set_block("default:diamondblock", above_player)
  ```

**`mod.set_area(block_name, position1, position2)`**

- **What it does:** Fills a rectangular area with a specific block.
- **What you need:**
  - `block_name`: Which block to use.
  - `position1`: One corner of the area.
  - `position2`: The second, opposite corner.
- **Example:**
  ```lua
  -- Creates a swimming pool of water
  local pos1 = mod.position(0, -1, 0)
  local pos2 = mod.position(10, -1, 10)
  mod.set_area("default:water_source", pos1, pos2)
  ```

**`mod.cube(block_name, position, size)`**

- **What it does:** Creates a cube of blocks.
- **What you need:**
  - `block_name`: Which block to use.
  - `position`: Center of the cube.
  - `size`: How big the cube should be.
- **Example:**
  ```lua
  -- Creates a 5x5x5 gold cube at player position
  mod.cube("default:goldblock", mod.player_pos(), 5)
  ```

**`mod.sphere(block_name, position, radius)`**

- **What it does:** Creates a sphere of blocks.
- **What you need:**
  - `block_name`: Which block to use.
  - `position`: Center of the sphere.
  - `radius`: How big the sphere should be.
- **Example:**
  ```lua
  -- Creates a glass dome over the player
  mod.sphere("default:glass", mod.player_pos(), 10)
  ```

**`mod.tree(position, type)`**

- **What it does:** Grows a tree at a location.
- **What you need:**
  - `position`: Where the tree should grow.
  - `type`: What kind of tree (options: `tree`, `apple`, `jungle`, `emergent`, `pine`, `snow_pine`, `acacia`, `aspen`, `bush`, `blueberry`, `large_cactus`).
- **Example:**
  ```lua
  -- Grows a pine tree at player position
  mod.tree(mod.player_pos(), "pine")
  ```

---

## Finding & Investigating Things

**`mod.read_block(position)`**

- **What it does:** Checks which block is at a specific location.
- **What you need:**
  - `position`: The location you want to check.
- **Example:**
  ```lua
  -- Find out what the player is standing on
  local player_pos = mod.player_pos()
  local ground_pos = mod.position(player_pos.x, player_pos.y - 1, player_pos.z)
  local block_name = mod.read_block(ground_pos)
  mod.chat("You're standing on: " .. block_name)
  ```

**`mod.find_block(start_position, distance, block_name)`**

- **What it does:** Searches for the nearest block of a specific type near you.
- **What you need:**
  - `start_position`: Where the search should start (e.g., `mod.player_pos()`).
  - `distance`: How far away to search (a number).
  - `block_name`: Which block to search for (e.g., `"default:diamond_ore"`).
- **Example:**
  ```lua
  -- Find a diamond nearby (radius of 10 blocks)
  local diamond_pos = mod.find_block(mod.player_pos(), 10, "default:diamond_ore")
  if diamond_pos then
    mod.chat("I found a diamond at " .. dump(diamond_pos) .. "!")
  end
  ```

---

## Creating Your Own Blocks & Items

This is the most exciting part! Here you can invent your own blocks and items with special abilities.

**`mod.new_block(name, texture, properties)`**

- **What it does:** Invents a completely new block that you can then find in the inventory and place in the world.
- **What you need:**
  - `name`: The name for your block (e.g., "Party Block").
  - `texture`: The name of the image file for the appearance (e.g., `"default_gold_block.png"`).
  - `properties`: A list of things the block should do.

- **Possible properties - Not all need to be specified!:**
  - `right_click = function(position)` - When a player right-clicks on the block.
  - `left_click = function(position)` - When a player left-clicks on the block.
  - `break_block = function(position)` - When the block is broken.

- **Example:** A teleporter block that brings you to a high place.
  ```lua
  mod.new_block("Teleporter", "default_obsidian.png", {
    right_click = function(position)
      mod.chat("Teleporting!")
      -- Teleports the player 100 blocks above the block
      local target_pos = mod.position(position.x, position.y + 100, position.z)
      mod.teleport_player(target_pos)
    end,
    left_click = function(position)
      mod.chat("This is a teleporter! Right-click to use it.")
    end,
    break_block = function(position)
      mod.chat("The teleporter was destroyed!")
    end
  })
  ```

**`mod.new_item(name, texture, properties)`**

- **What it does:** Invents a new item that you can hold in your hand and use.
- **What you need:**
  - `name`: The name for your item (e.g., "Tree Magic Wand").
  - `texture`: The name of the image file for the item (e.g., `"default_stick.png"`).
  - `properties`: A list of things the item should do.

- **Possible properties:**
  - `place = function(position, player)` - When you try to place the item like a block.
  - `left_click = function(block_position, player)` - When you left-click on a block with the item.
  - `right_click = function(player)` - When you right-click in the air with the item.

- **Example:** A magic wand that grows trees and turns blocks into gold.
  ```lua
  mod.new_item('Nature Magic Wand', 'default_stick.png', {
    -- Right-click to grow a tree
    place = function(position)
      mod.tree(position, 'apple')
      mod.chat('An apple tree appears!')
    end,
    -- Left-click to turn a block into gold
    left_click = function(block_position)
      mod.set_block('default:goldblock', block_position)
      mod.chat('Turned into gold!')
    end,
    -- Right-click in air for particle effect
    right_click = function()
      mod.particles(mod.player_pos(), 'heart.png', 200, 10)
    end,
  })
  ```

---

## Player & Physics

**`mod.player_pos()`**

- **What it does:** Gives you the current position of the player. Very useful!
- **Example:**
  ```lua
  -- Save player position in a "box"
  local my_position = mod.player_pos()
  -- Place a torch block exactly under the player
  mod.set_block("default:torch", my_position)
  ```

**`mod.teleport_player(position)`**

- **What it does:** Teleports the player to another location.
- **What you need:**
  - `position`: Where you want to travel.
- **Example:**
  ```lua
  -- Teleports the player 100 blocks into the air
  mod.teleport_player(mod.position(0, 100, 0))
  ```

**`mod.set_gravity(strength)`**

- **What it does:** Changes gravity.
- **What you need:**
  - `strength`: A number. `1` is normal. Less than 1 (e.g., `0.1`) is like on the moon, more than 1 (e.g., `3`) pulls you down strongly.
- **Example:**
  ```lua
  -- Almost no gravity!
  mod.set_gravity(0.1)
  ```

---

## Special Effects

**`mod.particles(position, texture, amount, range)`**

- **What it does:** Creates cool particle effects (like sparks or smoke).
- **What you need:**
  - `position`: Where the particles should appear.
  - `texture`: The appearance of the particles (e.g., `"fire_basic.png"`).
  - `amount`: How many particles there should be.
  - `range`: How far the particles spread.
- **Example:**
  ```lua
  -- Creates 100 fire particles around the player
  mod.particles(mod.player_pos(), "fire_basic.png", 100, 3)
  ```

**`mod.repeat_every(seconds, function)`**

- **What it does:** Executes code repeatedly after a certain time.
- **What you need:**
  - `seconds`: The interval in seconds between repetitions.
  - `function`: The code that should be repeated.
- **Example:**
  ```lua
  -- Writes "Hello" in chat every 10 seconds
  mod.repeat_every(10, function()
    mod.chat("Another 10 seconds have passed!")
  end)
  ```

---

## Useful Helper Functions

**`random(min, max)`**

- **What it does:** Gives you a random number.
- **Example:**
  ```lua
  -- Random number between 1 and 10
  local lucky_number = random(1, 10)
  mod.chat("Your lucky number is: " .. lucky_number)
  ```

**`wait(seconds, function)`**

- **What it does:** Waits a certain time, then executes code.
- **Example:**
  ```lua
  mod.chat("Explosion in 3 seconds!")
  wait(3, function()
    mod.particles(mod.player_pos(), "fire_basic.png", 500, 10)
    mod.chat("BOOM!")
  end)
  ```