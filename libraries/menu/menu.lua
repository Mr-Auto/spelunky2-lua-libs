
-- globals:
TEXT_ALIGNMENT = {
  LEFT = 0,
  CENTER = 1,
  RIGHT = 2
}

-- locals:
local menu_callbacks = {}

-- Menu class
Menu = {
    box = AABB:new(),
    
    background = {
      color = 0xFF000000,
      padding = AABB:new(0.02, 0.02, 0.02, 0.02),
      rounding = 0.0,
    },
    callback_id = nil,
    
    items = {
      names = {},
      focus = 1, -- focused item
      color = {
        background = 0xFFA00000,
        hover = 0xFF00A000,
        text = 0xFFFFFFFF,
      },
      font_size = 20,
      text_align = TEXT_ALIGNMENT.CENTER,
      spacing = 0.03,     -- space between the "buttons"
      padding = AABB:new(),
      size = {0.0, 0.0}, -- horizontal, vertical, zero means automatic
      height = 0.0,      -- internal use only
      rounding = 1.0,
    },
    key_binds = {
      up = INPUTS.UP,
      down = INPUTS.DOWN,
      confirm = INPUTS.WHIP,
    },
    last_draw_frame = nil,
}
-- functions:
function Menu:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Menu:set_callback(func)
    if self.callback_id ~= nil then
        self:clear_callback()
    end
    table.insert(menu_callbacks, {func, self})
    self.callback_id = #menu_callbacks
end

function Menu:clear_callback()
    if self.callback_id ~= nil then
        menu_callbacks[self.callback_id] = nil
        self.callback_id = nil
    end
end

function Menu:center (v, h)
    self:update_box()
    if v == true or v == nil then
        local size = self.box:height()
        self.box.top = size / 2
        self.box.bottom = -size / 2
    end
    if h == true or h == nil then
        local size = self.box:width()
        self.box.left = -size / 2
        self.box.right = size / 2
    end
end

function Menu:set_pos (x, y)
    self.box.left = x
    self.box.right = y
    self:update_box()
end

function Menu:update_box()

    self.box.right = self.box.left + self.background.padding.left + self.background.padding.right
    self.box.bottom = self.box.top - (self.background.padding.top + self.background.padding.bottom)
    
    text_width, text_height = draw_text_size(self.items.font_size, self.items.names[1])
    
    if self.items.size[1] ~= 0.0 then -- horizontal
        
        self.box.right = self.box.right + self.items.size[1]
        
    else
        for _, stext in ipairs(self.items.names) do
            tw, _ = draw_text_size(self.items.font_size, stext)
            if tw > text_width then
                text_width = tw
            end
        end
        self.box.right = self.box.right + text_width + self.items.padding.left + self.items.padding.right
        
    end
    
    if self.items.size[2] ~= 0.0 then -- vertical
        self.items.height = self.items.size[2]
    else
        self.items.height = -text_height + self.items.padding.top + self.items.padding.bottom
    end
    self.box.bottom = self.box.bottom - (((self.items.height + self.items.spacing) * #self.items.names) - self.items.spacing)
end

function Menu:draw (draw_ctx)
    
    -- background
    self.last_draw_frame = get_frame()
    draw_ctx:draw_rect_filled(self.box, self.background.rounding, self.background.color)
    
    item_box = AABB:new(self.box.left + self.background.padding.left,
      self.box.top - self.background.padding.top,
      self.box.right - self.background.padding.right,
      self.box.top - self.background.padding.top - self.items.height
    )
    
    for idx, _ in ipairs(self.items.names) do
        if idx ~= 1 then
            item_box:offset(0, -(item_box:height() + self.items.spacing))
        end
        local box_color = 0
        if self.items.focus == idx then
            box_color = self.items.color.hover
        else
            box_color = self.items.color.background
        end
        
        text_offset = 0
        if self.items.text_align == 1 then -- center
            text_width, _ = draw_text_size(self.items.font_size, self.items.names[idx])
            text_offset = ((item_box:width() - self.items.padding.left - self.items.padding.right) - text_width) * 0.5
        elseif self.items.text_align == 2 then -- right
            text_width, _ = draw_text_size(self.items.font_size, self.items.names[idx])
            text_offset = ((item_box:width() - self.items.padding.left - self.items.padding.right) - text_width)
        end
        text_position = item_box.left + text_offset + self.items.padding.left
        
        
        draw_ctx:draw_rect_filled(item_box, self.items.rounding, box_color)
        draw_ctx:draw_text(text_position, item_box.top - self.items.padding.top, self.items.font_size, self.items.names[idx], self.items.color.text) 
    end
end

local last_inputs = 0

-- active stuff:
set_callback(function()

    new_inputs = state.player_inputs.player_slots[1].buttons
    for idx, v in pairs(menu_callbacks) do
        if v[2].last_draw_frame == nil or math.abs(v[2].last_draw_frame - get_frame()) <= 1 then
        
            test_inputs = (new_inputs ~ (new_inputs & last_inputs))
            if test_inputs & v[2].key_binds.up ~= 0 then
                v[2].items.focus = v[2].items.focus - 1
            elseif test_inputs & v[2].key_binds.down ~= 0 then
                v[2].items.focus = v[2].items.focus + 1
            elseif test_inputs & v[2].key_binds.confirm ~= 0 then
                v[1](v[2].items.focus)
            end
            if v[2].items.focus > #v[2].items.names then
                v[2].items.focus = 1
            elseif v[2].items.focus < 1 then
                v[2].items.focus = #v[2].items.names
            end
        end
    end
    last_inputs = new_inputs

end, ON.GAMEFRAME)
