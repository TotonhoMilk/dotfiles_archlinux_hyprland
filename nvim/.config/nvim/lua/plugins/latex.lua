return {
  {
    "lervag/vimtex",
    lazy = false, -- Recommended to not lazy-load VimTeX for inverse search
    init = function()
      -- Use tectonic as the compiler
      vim.g.vimtex_compiler_method = "tectonic"
      -- Set Zathura as the default PDF viewer
      vim.g.vimtex_view_method = "zathura"
    end,
  },
}
