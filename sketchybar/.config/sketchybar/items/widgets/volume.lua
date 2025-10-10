local colors = require("colors")
local icons = require("icons")

local popup_width = 250

local volume_icon = sbar.add("item", "widgets.volume1", {
  position = "right",
  icon = {
    drawing = false,
  },
  label = {
    width = 22,
  },
  popup = { align = "center" }
})

local volume_slider = sbar.add("slider", popup_width, {
  position = "popup." .. volume_icon.name,
  slider = {
    highlight_color = colors.blue,
    background = {
      height = 6,
      corner_radius = 3,
      color = colors.bg2,
    },
    knob= {
      string = "􀀁",
      drawing = true,
    },
  },
  background = { color = colors.bg1, height = 2, y_offset = -20 },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"'
})

volume_icon:subscribe("volume_change", function(env)
  local volume = tonumber(env.INFO)
  local icon = icons.volume._0
  if volume > 60 then
    icon = icons.volume._100
  elseif volume > 30 then
    icon = icons.volume._66
  elseif volume > 10 then
    icon = icons.volume._33
  elseif volume > 0 then
    icon = icons.volume._10
  end

  volume_icon:set({ label = icon })
  volume_slider:set({ slider = { percentage = volume } })
end)

local function volume_collapse_details()
  local drawing = volume_icon:query().popup.drawing == "on"
  if not drawing then return end
  volume_icon:set({ popup = { drawing = false } })
  sbar.remove('/volume.device\\.*/')
end

local popup_timer_id = 0

local current_audio_device = "None"
local function volume_toggle_details(env)
  if env.BUTTON == "right" then
    sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
    return
  end

  local should_draw = volume_icon:query().popup.drawing == "off"
  if should_draw then
    -- Increment timer ID to invalidate any previous timers
    popup_timer_id = popup_timer_id + 1
    local current_timer_id = popup_timer_id
    
    volume_icon:set({ popup = { drawing = true } })
    
    -- Auto-hide timer: close popup after 5 seconds
    sbar.exec("sleep 5", function()
      -- Only close if this is still the current timer
      if current_timer_id == popup_timer_id then
        volume_icon:set({ popup = { drawing = false } })
        sbar.remove('/volume.device\\.*/')
      end
    end)
    sbar.exec("SwitchAudioSource -t output -c", function(result)
      current_audio_device = result:sub(1, -2)
      sbar.exec("SwitchAudioSource -a -t output", function(available)
        current = current_audio_device
        local counter = 0

        local active_color = colors.blue
        local inactive_color = colors.with_alpha(colors.black, 0.7)

        for device in string.gmatch(available, '[^\r\n]+') do
          local color = inactive_color
          if current == device then
            color = active_color
          end
          sbar.add("item", "volume.device." .. counter, {
            position = "popup." .. volume_icon.name,
            width = popup_width,
            align = "center",
            label = {
              string = device,
              color = color,
            },
            click_script = 'SwitchAudioSource -s "' .. device .. '" && sketchybar --set /volume.device\\.*/ label.color=' .. inactive_color .. ' --set $NAME label.color=' .. active_color .. ' --set ' .. volume_icon.name .. ' popup.drawing=off'
          })
          counter = counter + 1
        end
      end)
    end)
  else
    -- Increment timer ID to cancel any running timers
    popup_timer_id = popup_timer_id + 1
    volume_collapse_details()
  end
end

local function volume_scroll(env)
  local delta = env.INFO.delta
  if not (env.INFO.modifier == "ctrl") then delta = delta * 10.0 end

  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe("mouse.clicked", volume_toggle_details)
volume_icon:subscribe("mouse.scrolled", volume_scroll)
