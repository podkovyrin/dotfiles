return {
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    opts = {
      style = "light",
    },
    config = function(_, opts)
      local onedark = require("onedark")
      onedark.setup(opts)
      onedark.load()
    end,
  },
}
