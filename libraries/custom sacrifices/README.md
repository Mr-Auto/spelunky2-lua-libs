# Custom Sactifices

Let's you make items able to be sacrificed on kali altar that normally can't. You can't edit entities that normally can be sacrificed in game with this mod, trying to add them may do some weird stuff.
all you have to do is put the file "sacrifice.lua" in the same directory as your script file (like main.lua for standard mods) and then in your script file add simply 

```
require "sacrifice"
```
There is no need to edit the file "sacrifice.lua" in any way, of course you're free to if you want :)

and now you have full functionality and can use the provided function:

## add_sacrifice(entType, add_favor, required_favor)
##### Arguments:
- **entType** - entity type, for ex. `ENT_TYPE.ITEM_CRABMAN_CLAW`
- **add_favor** - amount of favor that the player will get for sacrificing this entity, for ex. sacrificing a live pet gives you 8 favor, can by any whole number, even 0 or negative
- **required_favor** - amount of favor that is required for the player to have to be able to sacrifice this entity, like you need 16 favor to be able to sacrifice a rock, don't use it or set it to **nil** to disable

example:
```lua
require "sacrifice"

add_sacrifice(ENT_TYPE.ITEM_CRABMAN_CLAW, 10, 1)

```
This will make the crab-man claw able to be sacrificed but only if you have at least 1 favor, sacrificing it will give you 10 favor

You can also change the values on the go if needed, so for ex. item will give you less and less favor the more you sacrifice it, just call the function the same way with different values.
If you don't wont to sacrifice any more, simply set the **required_favor** argument to something high like `999`


Callback (sort of): that's called when item is being sacrificed
```lua
require "sacrifice"

add_sacrifice(ENT_TYPE.ITEM_CRABMAN_CLAW, 0) --no favor required, no favor given

function on_sacrifice(entType, altar)

	if entType == ENT_TYPE.ITEM_CRABMAN_CLAW then
		x, y, l = get_position(altar)
		spawn(ENT_TYPE.ITEM_PLASMACANNON, x, y + 1.0, l, 0, 0)
	end
end
```
This will spawn plasma cannon if you sacrifice crab-man claw, you won't gain any kali favor

##### Known issues:
- it is possible to pick up the item at the right time and have the sacrificing effect, it can also gives you item if the favor amount is met, but it's frame perfect and the amount of favor does not add up (so doing this couple of times will not do anything at all, just flashing sacrificing effect)


You don't need to credit anyone if you want to use this, you also free to modify it as you want

Thanks to **Trixelized** for some great ideas that make this work.
