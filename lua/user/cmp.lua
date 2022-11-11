local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
	return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
	return
end

local compare = require("cmp.config.compare")

-- load vscode snippets
require("luasnip/loaders/from_vscode").lazy_load()

-- load custom snippets if they exist
if vim.fn.empty(vim.fn.glob("~/.config/snippets")) == 0 then
	require("luasnip/loaders/from_vscode").lazy_load({ paths = { "~/.config/snippets" } })
end

-- Common function
local check_backspace = function()
	local line, col = string.unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local icons = require("user.icons")
local kind_icons = icons.kind

vim.api.nvim_set_hl(0, "CmpItemKindEmoji", { fg = "#FDE030" })

vim.g.cmp_active = true

cmp.setup({
	enabled = function()
		local buftype = vim.api.nvim_buf_get_option(0, "buftype")
		if buftype == "prompt" then
			return false
		end
		return vim.g.cmp_active
	end,
	preselect = cmp.PreselectMode.None,
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
		["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<m-o>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),

		-- disable mapping
		["<C-c>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		["<m-j>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		["<m-k>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		["<m-c>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		["<S-CR>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),

		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Right>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.jumpable(1) then
				luasnip.jump(1)
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif luasnip.expandable() then
				luasnip.expand()
			elseif check_backspace() then
				fallback()
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
	}),
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			vim_item.kind = kind_icons[vim_item.kind]

			if entry.source.name == "cmp_tabnine" then
				vim_item.kind = icons.misc.Robot
			end

			if entry.source.name == "emoji" then
				vim_item.kind = icons.misc.Smiley
				vim_item.kind_hl_group = "CmpItemKindEmoji"
			end

			vim_item.menu = ""
			return vim_item
		end,
	},
	sources = {
		{ name = "path", group_index = 2 },
		{ name = "nvim_lsp", group_index = 2, keyword_length = 3 },
		--[[ { name = "nvim_lsp_signature_help", group_index = 2 }, ]]
		{ name = "nvim_lua", group_index = 2, keyword_length = 2 },
		{ name = "luasnip", group_index = 2, keyword_length = 2 },
		{ name = "buffer", group_index = 2, keyword_length = 2 },
		{ name = "cmp_tabnine", group_index = 2, keyword_length = 2 },
		{ name = "emoji", group_index = 2 },
	},
	confirm_opts = {
		behavior = cmp.ConfirmBehavior.Replace,
		select = false,
	},

	sorting = {
		priority_weight = 2,
		comparators = {
			compare.offset,
			compare.exact,
			compare.score,
			compare.recently_used,
			compare.locality,
			compare.sort_text,
			compare.length,
			compare.order,
		},
	},
	window = {
		documentation = false,
		completion = {
			border = "rounded",
			winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
		},
	},
	experimental = {
		ghost_text = true,
	},
})
