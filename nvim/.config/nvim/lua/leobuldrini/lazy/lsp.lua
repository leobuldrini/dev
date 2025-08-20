return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "stevearc/conform.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-cmdline",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "j-hui/fidget.nvim",
  },

  config = function()
    -- NÃO configurar conform aqui, já está em conform.lua
    local cmp = require('cmp')
    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities())

    require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        -- Existentes
        "lua_ls",
        "rust_analyzer",
        "gopls",
        "tailwindcss",
        -- Novos LSPs
        "clangd",           -- C/C++ LSP
        "pyright",          -- Python type checking
        "ruff",             -- Python linting/formatting
        -- Opcionais para debugging
        -- "debugpy",       -- Python debugger
        -- "codelldb",      -- C/C++ debugger
      },
      handlers = {
        function(server_name) -- handler padrão
          require("lspconfig")[server_name].setup {
            capabilities = capabilities
          }
        end,

        zls = function()
          local lspconfig = require("lspconfig")
          lspconfig.zls.setup({
            root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
            settings = {
              zls = {
                enable_inlay_hints = true,
                enable_snippets = true,
                warn_style = true,
              },
            },
          })
          vim.g.zig_fmt_parse_errors = 0
          vim.g.zig_fmt_autosave = 0
        end,

        ["lua_ls"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                format = {
                  enable = false,  -- IMPORTANTE: Desabilitar para usar stylua
                },
                diagnostics = {
                  globals = { "vim" }  -- Reconhecer vim global
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                telemetry = {
                  enable = false,
                },
              }
            }
          }
        end,

        ["tailwindcss"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.tailwindcss.setup({
            capabilities = capabilities,
            filetypes = { "html", "css", "scss", "javascript", "javascriptreact",
                          "typescript", "typescriptreact", "vue", "svelte" },
            settings = {
              tailwindCSS = {
                experimental = {
                  classRegex = {
                    "tw`([^`]*)",
                    "tw=\"([^\"]*)",
                    "tw={\"([^\"}]*)",
                    "tw\\.\\w+`([^`]*)",
                    "tw\\(.*?\\)`([^`]*)",
                  },
                },
              },
            },
          })
        end,

        -- NOVA CONFIGURAÇÃO: C/C++
        ["clangd"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.clangd.setup({
            capabilities = capabilities,
            cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--fallback-style=llvm",
            },
            init_options = {
              usePlaceholders = true,
              completeUnimported = true,
              clangdFileStatus = true,
            },
            root_dir = lspconfig.util.root_pattern(
              "Makefile",
              "configure.ac",
              "meson.build",
              "compile_commands.json",
              "compile_flags.txt",
              ".git"
            ),
          })
        end,

        -- NOVA CONFIGURAÇÃO: Python (Pyright)
        ["pyright"] = function()
          local lspconfig = require("lspconfig")

          -- Função para detectar virtual environment
          local function get_python_path()
            -- Primeiro, verifica se há um venv ativo
            if vim.env.VIRTUAL_ENV then
              return vim.env.VIRTUAL_ENV .. "/bin/python"
            end

            -- Procura por venv no projeto
            local venv_paths = {
              vim.fn.getcwd() .. "/venv/bin/python",
              vim.fn.getcwd() .. "/.venv/bin/python",
              vim.fn.getcwd() .. "/env/bin/python",
            }

            for _, path in ipairs(venv_paths) do
              if vim.fn.executable(path) == 1 then
                return path
              end
            end

            -- Fallback para python3 do sistema
            return vim.fn.exepath("python3") or "python"
          end

          lspconfig.pyright.setup({
            capabilities = capabilities,
            settings = {
              pyright = {
                disableOrganizeImports = true,  -- Ruff fará isso
              },
              python = {
                analysis = {
                  typeCheckingMode = "basic",
                  autoSearchPaths = true,
                  useLibraryCodeForTypes = true,
                  diagnosticMode = "workspace",
                },
                pythonPath = get_python_path(),
              }
            },
            before_init = function(_, config)
              config.settings.python.pythonPath = get_python_path()
            end,
          })
        end,

        -- NOVA CONFIGURAÇÃO: Python (Ruff)
        ["ruff"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.ruff.setup({
            capabilities = capabilities,
            on_attach = function(client, _)
              -- Desabilitar hover do Ruff (usar Pyright para isso)
              client.server_capabilities.hoverProvider = false
            end,
            init_options = {
              settings = {
                -- Configurações do Ruff
                args = {},
              }
            }
          })
        end,

        -- NOVA CONFIGURAÇÃO: Dart (se não usar flutter-tools)
        ["dartls"] = function()
          -- Só configurar se NÃO estiver usando flutter-tools.nvim
          -- Se usar flutter-tools, comentar esta configuração
          local lspconfig = require("lspconfig")
          lspconfig.dartls.setup({
            capabilities = capabilities,
            cmd = { "dart", "language-server", "--protocol=lsp" },
            filetypes = { "dart" },
            root_dir = lspconfig.util.root_pattern("pubspec.yaml"),
            init_options = {
              closingLabels = true,
              flutterOutline = true,
              onlyAnalyzeProjectsWithOpenFiles = true,
              outline = true,
              suggestFromUnimportedLibraries = true,
            },
            settings = {
              dart = {
                completeFunctionCalls = true,
                showTodos = true,
                enableSnippets = true,
                updateImportsOnRename = true,
                documentation = "full",
                analysisExcludedFolders = {
                  ".dart_tool",
                  "build",
                },
              }
            }
          })
        end,
      }
    })

    -- Configuração do nvim-cmp (mantém a existente)
    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources({
        { name = "copilot", group_index = 2 },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      }, {
        { name = 'buffer' },
      })
    })

    vim.diagnostic.config({
      -- update_in_insert = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })
  end
}
