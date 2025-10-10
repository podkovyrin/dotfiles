local colors = require("colors")
local settings = require("settings")

-- Hardcoded list of available keyboard layouts to cycle through on click
local layouts = {
  "com.apple.keylayout.US",
  "com.apple.keylayout.Russian",
  -- "com.apple.keylayout.Dutch"
}

-- Map layout IDs to display abbreviations
local layout_labels = {
  ["com.apple.keylayout.US"] = "US",
  ["com.apple.keylayout.Russian"] = "RU",
  ["com.apple.keylayout.Dutch"] = "NL"
}

local language_icon = sbar.add("item", "widgets.language", {
  position = "right",
  icon = {
    drawing = false,
  },
  label = {
    string = "US",
    align = "center",
    color = colors.white,
  },
})

-- Function to get current layout and update display
local function update_language_display()
  sbar.exec("im-select", function(result)
    if result then
      local current_layout = result:gsub("%s+", "") -- trim whitespace
      local display_label = layout_labels[current_layout] or "??"
      language_icon:set({ label = { string = display_label } })
    end
  end)
end

local function cycle_language()
  sbar.exec("im-select", function(result)
    if result then
      local current_layout = result:gsub("%s+", "") -- trim whitespace
      local current_index = 1
      
      -- Find current layout index
      for i, layout in ipairs(layouts) do
        if layout == current_layout then
          current_index = i
          break
        end
      end
      
      -- Get next layout (cycle back to 1 if at end)
      local next_index = (current_index % #layouts) + 1
      local next_layout = layouts[next_index]
      
      -- Switch to next layout
      sbar.exec("im-select " .. next_layout, function()
        -- Update display after switching
        update_language_display()
      end)
    end
  end)
end

language_icon:subscribe("mouse.clicked", function(env)
  cycle_language()
end)

sbar.add("event", "keyboard_change", "AppleSelectedInputSourcesChangedNotification")

language_icon:subscribe("keyboard_change", function(env)
  update_language_display()
end)

update_language_display()
