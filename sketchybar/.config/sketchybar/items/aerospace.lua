local colors = require("colors")

sbar.add("event", "aerospace_workspace_change")

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

local aerospace_item = sbar.add("item", "space.focused", {
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
    string = "1",
    color = colors.white,
    width = 30,
    align = "center",
  },
  padding_left = 1,
  padding_right = 1,
})

aerospace_item:subscribe("aerospace_workspace_change", function(env)
  local workspaces_with_windows_now = get_workspaces_with_windows()
  local focused_workspace = env.FOCUSED_WORKSPACE
  local has_windows_now = workspaces_with_windows_now[focused_workspace] == true
  local label_color = has_windows_now and colors.white or colors.grey

  aerospace_item:set({
    label = {
      string = focused_workspace,
      color = label_color
    }
  })
end)
