-- ARQUIVO OPCIONAL: Apenas se você desenvolver Flutter/Dart
-- Salvar em: /home/leonardo/dotfiles/nvim/.config/nvim/lua/leobuldrini/lazy/flutter.lua

return {
  "nvim-flutter/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- "stevearc/dressing.nvim", -- opcional: UI melhor para selects
  },
  ft = { "dart" },  -- Carrega apenas quando abrir arquivo .dart
  config = function()
    require("flutter-tools").setup({
      ui = {
        border = "rounded",
        notification_style = "native",  -- ou 'plugin' se tiver nvim-notify
      },

      decorations = {
        statusline = {
          app_version = true,
          device = true,
          project_config = true,
        }
      },

      lsp = {
        color = {
          enabled = true,  -- Mostra cores no código (ex: Colors.blue)
          background = false,  -- Colore o background
          background_color = nil,
          foreground = false,  -- Colore o texto
          virtual_text = true,  -- Mostra cor como virtual text
          virtual_text_str = "■",  -- Símbolo para mostrar a cor
        },

        on_attach = function(client, bufnr)
          -- Suas keybindings customizadas para Dart/Flutter
          local opts = { buffer = bufnr }

          -- Comandos específicos do Flutter
          vim.keymap.set("n", "<leader>fc", "<cmd>Telescope flutter commands<cr>", opts)
          vim.keymap.set("n", "<leader>fd", "<cmd>FlutterDevices<cr>", opts)
          vim.keymap.set("n", "<leader>fe", "<cmd>FlutterEmulators<cr>", opts)
          vim.keymap.set("n", "<leader>fr", "<cmd>FlutterReload<cr>", opts)
          vim.keymap.set("n", "<leader>fR", "<cmd>FlutterRestart<cr>", opts)
          vim.keymap.set("n", "<leader>fq", "<cmd>FlutterQuit<cr>", opts)
          vim.keymap.set("n", "<leader>ft", "<cmd>FlutterOutlineToggle<cr>", opts)
        end,

        capabilities = function(config)
          config = config or {}
          config.textDocument = config.textDocument or {}
          config.textDocument.codeAction = {
            dynamicRegistration = false,
            codeActionLiteralSupport = {
              codeActionKind = {
                valueSet = {
                  "",
                  "quickfix",
                  "refactor",
                  "refactor.extract",
                  "refactor.inline",
                  "refactor.rewrite",
                  "source",
                  "source.organizeImports",
                }
              }
            }
          }
          return config
        end,

        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          updateImportsOnRename = true,
          enableSnippets = true,
          documentation = "full",
          -- Análise
          analysisExcludedFolders = {
            ".dart_tool/",
            ".flutter/",
            ".pub-cache/",
            "build/",
          },
          -- Widget guides
          flutterOutline = true,
          closingLabels = true,
        }
      },

      widget_guides = {
        enabled = true,  -- Mostra linhas guia conectando widgets
      },

      closing_tags = {
        enabled = true,  -- Mostra labels de fechamento para widgets
        highlight = "Comment",  -- Cor do highlight
        prefix = "// ",  -- Prefixo para o label
        priority = 10,
      },

      dev_tools = {
        autostart = false,  -- Auto iniciar devtools
        auto_open_browser = false,  -- Auto abrir browser
      },

      dev_log = {
        enabled = true,
        notify_errors = false,  -- Notifica erros no log
        open_cmd = "tabedit",  -- Comando para abrir o log
        focus_on_open = false,  -- Focar no log quando abrir
      },

      debugger = {
        enabled = true,  -- Habilita debugging
        run_via_dap = true,  -- Usa nvim-dap se disponível
        register_configurations = function(_)
          -- Configurações de debug customizadas
          -- require("dap").configurations.dart = { ... }
        end,
      },

      -- Detecta automaticamente flutter SDK
      flutter_path = nil,  -- nil = auto detecta
      flutter_lookup_cmd = nil,  -- Comando para encontrar flutter

      -- Detecta automaticamente o projeto
      root_patterns = { ".git", "pubspec.yaml" },

      -- Configuração do fvm (Flutter Version Management)
      fvm = false,  -- true se usar fvm
    })

    -- Comandos globais úteis
    vim.api.nvim_create_user_command("FlutterRun", function()
      require("flutter-tools.commands").run()
    end, {})

    vim.api.nvim_create_user_command("FlutterDevicesSelect", function()
      require("flutter-tools.commands").select_device()
    end, {})

    -- Telescope extension (se usar telescope)
    pcall(function()
      require("telescope").load_extension("flutter")
    end)
  end,

  -- Keymaps principais (carregados apenas quando necessário)
  keys = {
    { "<leader>Fr", "<cmd>FlutterRun<cr>", desc = "Flutter Run" },
    { "<leader>Fq", "<cmd>FlutterQuit<cr>", desc = "Flutter Quit" },
    { "<leader>Fl", "<cmd>FlutterReload<cr>", desc = "Flutter Hot Reload" },
    { "<leader>FR", "<cmd>FlutterRestart<cr>", desc = "Flutter Restart" },
    { "<leader>Fd", "<cmd>FlutterDevices<cr>", desc = "Flutter Devices" },
    { "<leader>Fe", "<cmd>FlutterEmulators<cr>", desc = "Flutter Emulators" },
    { "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Flutter Widget Outline" },
    { "<leader>Fv", "<cmd>FlutterVisualDebug<cr>", desc = "Flutter Visual Debug" },
    { "<leader>Fc", "<cmd>Telescope flutter commands<cr>", desc = "Flutter Commands" },
    { "<leader>Fs", "<cmd>FlutterLspRestart<cr>", desc = "Restart Flutter LSP" },
  }
}
