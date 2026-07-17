return {
	"snacks.nvim",
	opts = {
		indent = { enabled = true },
		input = { enabled = true },
		notifier = { enabled = true },
		scope = { enabled = true },
		scroll = {
			enabled = true,
			animate = {
				duration = 1,
				-- easing = "linear",
				fps = 60,
			},
		},
		statuscolumn = { enabled = false }, -- we set this in options.lua
		words = { enabled = true },
		dashboard = {
			preset = {
				header = [[
                         .                                    .    o8o  oooo           .   oooo                                                   .o8             .oooo.   
                        .o8                                  .o8    `"'  `888         .o8   `888                                                  "888           .dP""Y88b  
ooo. .oo.    .ooooo.  .o888oo      oooo  oooo  ooo. .oo.   .o888oo oooo   888       .o888oo  888 .oo.    .ooooo.        .ooooo.  ooo. .oo.    .oooo888                 ]8P' 
`888P"Y88b  d88' `88b   888        `888  `888  `888P"Y88b    888   `888   888         888    888P"Y88b  d88' `88b      d88' `88b `888P"Y88b  d88' `888               <88b.  
 888   888  888   888   888         888   888   888   888    888    888   888         888    888   888  888ooo888      888ooo888  888   888  888   888       o8o      `88b. 
 888   888  888   888   888 .       888   888   888   888    888 .  888   888         888 .  888   888  888    .o      888    .o  888   888  888   888       `"' o.   .88P  
o888o o888o `Y8bod8P'   "888"       `V88V"V8P' o888o o888o   "888" o888o o888o        "888" o888o o888o `Y8bod8P'      `Y8bod8P' o888o o888o `Y8bod88P"      o8o `8bd88P'   
                                                                                                                                                             `]P            
                                                                                                                                                                                                                                                                                                                                 '                  ]],
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
			},
		},
	},
  -- stylua: ignore
  keys = {
    { "<leader>n", function()
      if Snacks.config.picker and Snacks.config.picker.enabled then
        Snacks.picker.notifications()
      else
        Snacks.notifier.show_history()
      end
    end, desc = "Notification History" },
  },
}
