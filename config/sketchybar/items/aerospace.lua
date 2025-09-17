local colors = require("colors")

sbar.add("event", "aerospace_workspace_change")

-- Function to get aerospace workspaces using io.popen synchronously
local function get_aerospace_workspaces()
  --[[
  According to SbarLua docs, io.popen should not be used, so workspaces are hardcoded for now.
  https://github.com/FelixKratz/SbarLua/blob/main/README.md#important-remarks
  
  local workspaces = {}
  local handle = io.popen("aerospace list-workspaces --all")
  if handle then
    for line in handle:lines() do
      local workspace_id = line:match("^%s*(.-)%s*$") -- trim whitespace
      if workspace_id and workspace_id ~= "" then
        table.insert(workspaces, workspace_id)
      end
    end
    handle:close()
  end
  
  local qwerty_order = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", 
                        "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
                        "A", "S", "D", "F", "G", "H", "J", "K", "L",
                        "Z", "X", "C", "V", "B", "N", "M"}
  
  local order_map = {}
  for i, key in ipairs(qwerty_order) do
    order_map[key] = i
  end
  
  table.sort(workspaces, function(a, b)
    local order_a = order_map[a] or 999  -- Put unknown workspaces at the end
    local order_b = order_map[b] or 999
    if order_a == order_b then
      return a < b  -- Fallback to alphabetical for unknown workspaces
    end
    return order_a < order_b
  end)
  
  return workspaces
  ]]
  return {
    "1", "2", "3",
    "Q", "W", "E",
    "A", "S", "D",
    "Z", "X", "C",
  }
end

local workspaces = get_aerospace_workspaces()

for _, workspace_id in ipairs(workspaces) do
  local aerospace_item = sbar.add("item", "space." .. workspace_id, {
    position = "left",
    background = {
      color = colors.transparent,
      corner_radius = 5,
      height = 20,
      width = 30,
    },
    icon = {
      drawing = false,
    },
    label = {
      string = workspace_id,
      color = colors.white,
      width = 30,
      align = "center",
    },
    click_script = "aerospace workspace " .. workspace_id,
    padding_left = 1,
    padding_right = 1,
  })
  aerospace_item:subscribe("aerospace_workspace_change", function(env)
    sbar.animate("linear", 16, function()
      local color
      if env.FOCUSED_WORKSPACE == workspace_id then
        color = colors.bg1
      else
        color = colors.transparent
      end

      aerospace_item:set({
        background = {
          color = color
        }
      })
    end)
  end)
end
