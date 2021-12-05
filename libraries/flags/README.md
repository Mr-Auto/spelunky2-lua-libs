# Flags

Small library that helps with bit-wise operations.
When `require` this library you need to save what it returns into a variable, that variable will then give you access to all the features

```lua
    flag - require "flags"
```
Now the available functions:

`.b(f)` - returns the value of a bit, so `flag.b(5)` will return 16, this is the basic function unless you want to work with the raw values
`.BIT[f]` - same as above but it's array not function, which technically should be a little bit faster, f is limited to 1 - 32, can add more if needed
`.switch(soucre, f)` - returns `soucre` with the bit/flag given by the `f` switched
`.set(soucre, f)` - returns `soucre` with the bit/flag given by the `f` set to '1'
`unset(soucre, f)` - returns `soucre` with the bit/flag given by the `f` set to '0'

### Why use this instead of API's set_flag() function
The set_flag(), crl_flag() etc. in the api work by getting the number of a bit, not bit value (so skipping the `.b(f)` function)
It's not bad design but it means that if you want to change multiple flags you need to call this function that many times, not even mentioning making new flags from 0
It's very incontinent from my point of view, that's why i made this library

### Examples:

1. Create new flags with bits 2, 5, 10 and 12 set
```lua

flag - require "flags"

local new_flags = flag.b(2) | flag.b(5) | flag.b(10) | flag.b(12)

```
2. Switch set player flag to make him invisible and turn off gravity for him
```lua

flag - require "flags"

set_callback(function()

players[1].flags = flag.set(players[1].flags, flag.b(1) | flag.b(10))

end, ON.LEVEL)

```


