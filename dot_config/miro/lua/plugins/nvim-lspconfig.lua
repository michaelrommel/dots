-- config for language servers not supported by mason-lspconfig
return {
	"neovim/nvim-lspconfig",
	lazy = true,
	ft = {
		"sh", "bash", "zsh", "css", "gitcommit", "graphql", "html", "javascript",
		"json", "json5", "lua", "markdown", "python", "rust", "svelte", "text"
	},
	dependencies = {
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"saghen/blink.cmp",
		"aznhe21/actions-preview.nvim",
		-- separates the update intervals of lsp from autosaved files/buffers
		"antoinemadec/FixCursorHold.nvim",
	},
	config = function()
		-- set up border around the LspInfo window
		require("lspconfig.ui.windows").default_options.border = 'rounded'
		-- set the time before a lsp hover window appears
		vim.g.cursorhold_updatetime = 500
		-- set up generic handlers and capabilities
		local on_attach = require("configs.conf_lsp").on_attach
		local capabilities = vim.tbl_deep_extend("force",
			vim.lsp.protocol.make_client_capabilities(),
			require("blink.cmp").get_lsp_capabilities({}, false)
		)
		-- set up utility functions
		local function _suppress(diag, codes)
			-- jsonls doesn't really support json5
			-- remove some annoying errors
			for _, v in pairs(codes) do
				local idx = 1
				while diag ~= nil and idx <= #diag do
					if diag[idx].code == v then
						print("suppressing: " .. idx .. "-" .. diag[idx].code)
						table.remove(diag, idx)
					else
						idx = idx + 1
					end
				end
			end
		end
		-- now set up all language servers
		require("lspconfig").bacon_ls.setup({
			filetypes = { "rust" },
			root_dir = require("lspconfig/util").root_pattern(
				"Cargo.toml", "rust-project.json"
			),
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				-- 	updateOnSave = true,
				-- 	updateOnSaveWaitMillis = 1000,
				updateOnChange = true,
				-- 	runBaconInBackground = true,
				-- 	createBaconPreferencesFile = true,
			}
		})
		require("lspconfig").bashls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "sh", "bash", "zsh" },
		})
		require("lspconfig").cssls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "css" },
			settings = {
				css = {
					-- customData = {
					-- 	"/tmp/tailwind.css-data.json"
					-- },
					lint = {
						unknownAtRules = 'ignore'
					}
				}
			}
		})
		require("lspconfig").eslint.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			root_dir = require("lspconfig/util").root_pattern(
				"package.json", "eslint.config.*"
			),
		})
		require("lspconfig").graphql.setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
		require("lspconfig").harper_ls.setup({
			filetypes = { "markdown", "gitcommit", "text" },
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				["harper-ls"] = {
					userDictPath = os.getenv("HOME") .. "/.config/harper-ls/dictionary.txt",
					fileDictPath = os.getenv("HOME") .. "/.config/harper-ls/file_dictionaries",
					linters = {
						Dashes = false,
						SpellCheck = true,
						SpelledNumbers = false,
						SentenceCapitalization = false,
						WrongQuotes = false,
						ToDoHyphen = false,
					},
					codeActions = {
						ForceStable = false
					},
					markdown = {
						IgnoreLinkTitle = false
					},
					diagnosticSeverity = "hint",
					isolateEnglish = false,
					dialect = "British"
				}
			}
		})
		require("lspconfig").html.setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
		require("lspconfig").jedi_language_server.setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
		require("lspconfig").jsonls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "json", "jsonc", "json5" },
			init_options = {
				provideFormatter = false,
			},
			handlers = {
				-- this is the push handling of diagnostics information
				["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
					if string.match(result.uri, "%.json5$", -6) and result.diagnostics ~= nil then
						-- 519: "Trailing comma""
						-- 521: "Comments are not permitted in JSON."
						_suppress(result.diagnostics, { 519, 521 })
					end
					vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
				end,
				-- this is the pull diagnostics method, in spec since 3.17.0
				["textDocument/diagnostic"] = function(err, result, ctx, config)
					local extension = vim.fn.fnamemodify(
						vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()),
						":e"
					)
					if string.match(extension, "json5$", -6) and result.items ~= nil then
						_suppress(result.items, { 521, 519 })
					end
					vim.lsp.diagnostic.on_diagnostic(err, result, ctx, config)
				end,
			},
		})
		require("lspconfig").lua_ls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "lua" },
			settings = {
				Lua = {
					diagnostics = {
						-- Get the language server to recognize the `vim` global
						globals = { 'vim' },
					},
					telemetry = {
						enable = false,
					},
				}
			}
		})
		require("lspconfig").ruff.setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
		require("lspconfig").rust_analyzer.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "rust" },
			cmd = { "rust-analyzer" },
			root_dir = require("lspconfig/util").root_pattern(
				"Cargo.toml", "rust-project.json"
			),
			single_file_support = true,
			settings = {
				['rust-analyzer'] = {
					diagnostics = {
						enable = true,
					},
					cargo = {
						allFeatures = true,
						buildScripts = {
							enable = true,
						}
					},
					checkOnSave = {
						enable = true,
						allFeatures = true,
						overrideCommand = {
							'cargo', 'clippy', '--workspace', '--message-format=json',
							'--all-targets', '--all-features'
						}
					},
				}
			}
		})
		require("lspconfig").svelte.setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
		require("lspconfig").tailwindcss.setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
		require("lspconfig").ts_ls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
	end
}
