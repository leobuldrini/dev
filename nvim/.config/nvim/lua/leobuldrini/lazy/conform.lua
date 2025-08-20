return {
  'stevearc/conform.nvim',
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        -- Linguagens existentes
        lua = { "stylua" },
        go = { "gofmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        elixir = { "mix" },

        -- NOVAS LINGUAGENS

        -- Python: Ruff para formatação e organização de imports
        python = {
          "ruff_format",           -- Formatação estilo Black
          "ruff_organize_imports"  -- Organização de imports estilo isort
        },

        -- C/C++: clang-format é o padrão da indústria
        c = { "clang_format" },
        cpp = { "clang_format" },
        cuda = { "clang_format" },  -- CUDA files também

        -- Dart: usa o formatter nativo do SDK
        dart = { "dart_format" },

        -- Extras úteis (já que está configurando)
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
      },

      -- Formatação ao salvar (opcional - descomente se quiser)
      -- format_on_save = {
      --   lsp_fallback = true,
      --   timeout_ms = 500,
      -- },

      -- Configurações customizadas para cada formatador
      formatters = {
        -- C/C++ formatter
        clang_format = {
          -- Usa .clang-format do projeto, senão usa estilo LLVM
          prepend_args = {
            "--style=file",        -- Procura .clang-format
            "--fallback-style=LLVM"  -- Se não achar, usa LLVM
          },
        },

        -- Python formatters
        ruff_format = {
          -- Configurações do Ruff formatter
          prepend_args = {
            -- "--line-length", "88",  -- Padrão Black
            -- "--indent-width", "4",  -- Indentação Python
          },
        },
        ruff_organize_imports = {
          -- Ruff organizando imports
          command = "ruff",
          args = {
            "check",
            "--select", "I",  -- Apenas regras de import
            "--fix",
            "--stdin-filename", "$FILENAME",
            "-",
          },
          stdin = true,
        },

        -- Dart formatter
        dart_format = {
          command = "dart",
          args = { "format", "$FILENAME" },
        },

        -- Configuração do Prettier (para JS/TS/Web)
        prettier = {
          prepend_args = {
            "--print-width", "100",
            "--tab-width", "2",
            "--use-tabs", "false",
            "--semi", "true",
            "--single-quote", "true",
            "--trailing-comma", "es5",
          },
        },

        -- Configuração do stylua (Lua)
        stylua = {
          prepend_args = {
            "--column-width", "100",
            "--indent-type", "Spaces",
            "--indent-width", "2",
            "--quote-style", "AutoPreferDouble",
          },
        },
      },

      -- Log level para debug (útil se tiver problemas)
      log_level = vim.log.levels.ERROR,

      -- Notificação quando formata
      notify_on_error = true,
    })

    -- Comando para formatar manualmente (já está no seu remap.lua como <leader>f)
    vim.api.nvim_create_user_command("Format", function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, end_line:len() },
        }
      end
      require("conform").format({ async = true, lsp_fallback = true, range = range })
    end, { range = true })
  end
}
