local codelens = require("vim.lsp.codelens")

local M = {}

function M.setup()
	vim.cmd("highlight default link LspCodeLens WarningMsg")
	vim.cmd("highlight default link LspCodeLensText WarningMsg")
	vim.cmd("highlight default link LspCodeLensTextSign LspCodeLensText")
	vim.cmd("highlight default link LspCodeLensTextSeparator Boolean")

	vim.cmd("augroup go.codelenses")
	vim.cmd("autocmd!")
	vim.cmd('autocmd BufEnter,CursorHold,InsertLeave <buffer> lua require("vim.lsp.codelens").refresh()')
	vim.cmd("augroup end")
end

function M.run_action()
	codelens.run()
	vim.defer_fn(function()
		vim.ui.select = vim.ui.select
	end, 1000)
end

function M.refresh()
	vim.lsp.codelens.refresh()
end

return M
