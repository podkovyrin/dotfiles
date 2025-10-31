local front_app = sbar.add("item", "front_app", {
  display = "active",
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({ label = { string = env.INFO } })
end)
