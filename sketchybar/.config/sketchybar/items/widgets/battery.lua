local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  icon = {
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    }
  },
  label = { font = { family = settings.font.numbers } },
  update_freq = 180,
  popup = { align = "center" }
})

battery:subscribe({"routine", "power_source_change", "system_woke"}, function()
  sbar.exec("pmset -g batt", function(batt_info)
    local icon = "!"
    local label = "?"

    local found, _, charge = batt_info:find("(%d+)%%")
    if found then
      charge = tonumber(charge)
      label = charge .. "%"
    end

    local color = colors.white
    local charging, _, _ = batt_info:find("AC Power")

    local label_config = {
      string = "",
      drawing = true,
      padding_left = 5,
    }

    if charging then
      icon = icons.battery.charging
      if found and charge == 100 then
        label_config.drawing = false
      end
    else
      if found and charge > 80 then
        icon = icons.battery._100
      elseif found and charge > 60 then
        icon = icons.battery._75
      elseif found and charge > 40 then
        icon = icons.battery._50
      elseif found and charge > 20 then
        icon = icons.battery._25
      else
        icon = icons.battery._0
        color = colors.red
      end
    end

    label_config.string = label

    battery:set({
      icon = {
        string = icon,
        color = color
      },
      label = label_config,
    })
  end)
end)
