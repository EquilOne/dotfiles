return {
	"folke/snacks.nvim",
	opts = {
		picker = {
			sources = {
				explorer = {
					layout = {
						preset = "vertical",
						preview = true,
					},
				},
			},
		},
		scroll = {
			enabled = true, -- Disable scrolling animations
		},
	},
}
