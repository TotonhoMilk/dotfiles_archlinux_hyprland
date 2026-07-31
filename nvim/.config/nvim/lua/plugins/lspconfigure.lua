-- Servidores LSP (qmlls, pyright, clangd)
-- Colocar o servidor dentro de opts.servers no nvim-lspconfig, o
-- plugin mason-lspconfig integrado já entende que precisa baixar e ativar esses LSPs
-- automaticamente via Mason

-- Ferramentas Extras (ruff, clang-format, debugpy, codelldb)
-- São servidores LSP clássicos (são formatadores/debuggers),
-- são passadas para a lista ensure_installed do próprio masson.nvim
-- O Mason vai checar se elas existem no sistema ao iniciar o neovim, e se não existirem, vai
-- baixá-las no fundo sem precisar digitar nada.

return {
  -- 1. Garante que o Mason instale automaticamente Formatters, Linters e Debuggers
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Formatadores e Linters
        "ruff", -- Python Linter / Formatter
        "clang-format", -- C/C++ Formatter

        -- Debuggers (DAP)
        "debugpy", -- Python Debugger
        "codelldb", -- C/C++ / Rust Debugger
      },
    },
  },

  -- 2. Configura os Language Servers (LSPs)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {

        -- Python
        pyright = {},

        -- C / C++
        clangd = {},
      },
    },
  },
}
