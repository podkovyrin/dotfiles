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

local function get_workspaces_with_windows()
  local workspaces_set = {}
  local handle = io.popen("aerospace list-workspaces --monitor all --empty no 2>/dev/null")
  if handle then
    for line in handle:lines() do
      local workspace_id = line:match("^%s*(.-)%s*$") -- trim whitespace
      if workspace_id and workspace_id ~= "" then
        workspaces_set[workspace_id] = true
      end
    end
    handle:close()
  end
  return workspaces_set
end

local workspaces = get_aerospace_workspaces()
local workspace_items = {}

local workspaces_with_windows = get_workspaces_with_windows()

for _, workspace_id in ipairs(workspaces) do
  local has_windows = workspaces_with_windows[workspace_id] == true
  local label_color = has_windows and colors.white or colors.with_alpha(colors.white, 0.75)
  
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
      color = label_color,
      width = 30,
      align = "center",
    },
    click_script = "aerospace workspace " .. workspace_id,
    padding_left = 1,
    padding_right = 1,
  })
  
  workspace_items[workspace_id] = aerospace_item
end

-- Use the first item's subscription to update ALL items
-- This ensures the event handler fires and updates all workspaces
workspace_items["1"]:subscribe("aerospace_workspace_change", function(env)
  local workspaces_with_windows_now = get_workspaces_with_windows()

  sbar.animate("linear", 16, function()
    for workspace_id, item in pairs(workspace_items) do
      local has_windows_now = workspaces_with_windows_now[workspace_id] == true
      local label_color = has_windows_now and colors.white or colors.grey

      local color
      if env.FOCUSED_WORKSPACE == workspace_id then
        color = colors.bg1
      else
        color = colors.transparent
      end

      item:set({
        label = {
          color = label_color
        },
        background = {
          color = color
        }
      })
    end
  end)
end)
