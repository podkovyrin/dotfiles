local colors = require("colors")

local cal = sbar.add("item", {
  icon = {
    color = colors.white,
  },
  label = {
    color = colors.white,
    width = 44,
    align = "right",
  },
  position = "right",
  update_freq = 1,
  click_script = "open -a 'Calendar'"
})

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
  cal:set({ icon = os.date("%a %e %b"), label = os.date("%H:%M") })
end)