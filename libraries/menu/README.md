# Menu

This library will help you make menus way easier with just few simple steps instead of making a mess with tons of drawing function etc.

To start, make a variable and assign new `Menu` to it


```lua
    require "menu"
    
    my_menu = Menu:new()
```
### Variables:
Use those to set up your menu:
- `.box` - It's the whole box of the menu, it's AABB type, the important part is `.left` and `.top` which determinate the position of the menu. You can also set the `.bottom` and `.right` but i recommend using function to do that automatically, default = default AABB value (four zeros)
- `.background` - table containing:
  - `.color` - color of the background, default = `0xFF000000`
  - `.padding` - padding, it's AABB type, default = `AABB:new(0.02, 0.02, 0.02, 0.02)`
  - `.rounding` - rounding of the box, just rounding parameter for the draw_rect function, default = `0.0`
- `.items` - table containing:
  - `.names` - table for the names of the buttons, also defines number of the buttons, default = `{}`
  - `.focus` - focused item, it's index of the `.names` table, this will change automatically when the player will move thru the menu, need to be reset manually, otherwise whe you open the menu again it will be focused on the button chosen when you closed the menu, default = `1`
  - `.color` - table containing:
    - `.background` - background color of the "button", default = `{0xFFA00000}`
    - `.hover` - color of the focused "button" background, default = `0xFF00A000`
    - `.text` - color of the text, default = `0xFFFFFFFF`
  - `.font_size` - font size parameter for the draw_text function, default = `20`
  - `.text_align` - text alignment, available options: `TEXT_ALIGNMENT.LEFT`, `TEXT_ALIGNMENT.CENTER`, `TEXT_ALIGNMENT.RIGHT`, default = `TEXT_ALIGNMENT.CENTER`
  - `.spacing` - space between the "buttons", default = `0.03`
  - `.padding` - padding of the "button", it's AABB type, default = default AABB value (four zeros)
  - `.size` - size of the "button", this is table of two values `{horizontal, vertical}`, zero means default (based on the text size and padding), if this is set to non 0, it will overwrite any padding for the `items`, default = `{0.0, 0.0}`
  - `.rounding` - rounding of the "button" box, just rounding parameter for the draw_rect function, default = `1.0`
- `.key_binds` - table containing:
  - `.up` - key for going up in the menu, use INPUTS enum, default = `INPUTS.UP`
  - `.down` - key for going down in the menu, use INPUTS enum, default = `INPUTS.DOWN`
  - `.confirm` - key for confirm the choice in the menu, use INPUTS enum, default = `INPUTS.WHIP`

#### Other:
Values for internal use only:
 - `.callback_id` - id of the callback, it will be set with `set_callback` function and reset with `clear_callback`
 - `.last_draw_frame` - last frame the Menu was drawn on screen, used for the inputs detection
 - `.items.height` - internal variable used for optimization
 

### Functions:
Use just like the functions for specific type in the API `my_menu:function(arguments)` (except the `new()` function)
 - `Menu:new()` - creates and returns new Menu object
 - `set_callback(func)` - creates callback, argument is a function that will be called when the player chooses option from menu, this will also start monitoring the inputs from the player
 - `clear_callback()` - clears the callback that was previously set with the above function
 - `center (vertical, horizontal)` - centers the menu, arguments are optional, if used without arguments it will center the menu horizontally and vertically, the arguments are bool type, this will also call `update_box()` function
 - `set_pos(x, y)` - just sets the position of the menu, also calls `update_box()` function
 - `update_box()` - function that will calculate the size of the box and other stuff to properly draw the menu, this is separate from the `draw` function for the optimization
 - `draw (draw_ctx)` - draws the menu on screen, this needs to be used inside ON.GUIFRAME callback, and requires `draw_ctx` available only in that callback
 
 ### Explanations, features and drawbacks
The order of operation is: create new menu object, set up the menu with desired variables, use `set_callback` to handle the logic when the players selects items from the menu, call `update_box`, `center` or `set_pos` function, make a logic that will call `draw` function when desired

If you don't specify the `.items.size` the `update_box` function will need to use `draw_text_size` function to determinate the size of the "buttons", this function currently has an issue of giving garbage value when called on game load (Playlunky load lua scripts as so as the game loads)
this mean you can't call `update_box` outside callbacks or in ON.LOAD callback, i recommend using like `ON.CAMP` and/or `ON.START` or `set_global_timeout` function in `ON.LOAD` to properly execute `update_box`. (This issue has been registered on Playlunky GitHub, hopefully it can be fixed)

Because this was made with class like structure, it is possible to store the Menu object with other objects, tables etc.
You can also expand the variables with custom ones without editing any of the `menu.lua` code, so you can have all the extra data tied to the menu itself

This is single player only (obviously) and uses only the player 1 controls for the menu, it is not affected by opening a game menu, in game death etc. any of this logic needs to be made by you

The draw_rect functions have a bug with the rounding argument, the fix is on the way. 

### Examples:

1. Fastest way to make a simple menu
```lua

require "menu"

local my_menu = Menu:new()
my_menu.items.names = {"Option A", "Option B", "Option C"}

set_callback(function()
    my_menu:center()
end, ON.START)

my_menu:set_callback(function()
    local selected_item = my_menu.items.focus
    message(my_menu.items.names[selected_item])
end)

set_callback(function(draw_ctx)
    my_menu:draw(draw_ctx)
end, ON.GUIFRAME)

```
When you use the whip button with the menu on screen, it will print the name of the button that is focused/hovered

2. Add custom var and some logic
```lua

require "menu"

local my_menu = Menu:new()
my_menu.items.names = {"Bomb Box", "Plasma Cannon", "PowerPack"}
my_menu.key_binds.confirm = INPUTS.DOOR

-- custom variables
my_menu.on = false
my_menu.gift_recived = false
-- ----

set_callback(function()
    my_menu:center()
end, ON.START)

my_menu:set_callback(function()
    my_menu.on = false

    x, y, l = get_position(players[1].uid)
    if my_menu.items.focus == 1 then
        spawn(ENT_TYPE.ITEM_PICKUP_BOMBBOX, x, y, l, 0, 0)
    elseif my_menu.items.focus == 2 then
        spawn(ENT_TYPE.ITEM_PLASMACANNON, x, y, l, 0, 0)
    elseif my_menu.items.focus == 3 then
        spawn(ENT_TYPE.ITEM_POWERPACK, x, y, l, 0, 0)
    end
    my_menu.items.focus = 1
end)

set_callback(funciton()

    if not my_menu.gift_recived and state.kali_favor >= 10 then
        my_menu.on = true
    end
end, ON.FRAME)

set_callback(function(draw_ctx)
    if my_menu.on then
        my_menu:draw(draw_ctx)
    end
end, ON.GUIFRAME)

```
This will open a menu when players reaches 10 kali favor, then he can choose his reward

