---@type vim.lsp.Config
return {
	cmd = { 'copilot-language-server', '--stdio' },
	root_markers = { '.git' },
	init_options = {
		editorInfo       = { name = 'Neovim', version = tostring(vim.version()) },
		editorPluginInfo = { name = 'Neovim', version = tostring(vim.version()) },
	},
	settings = { telemetry = { telemetryLevel = 'off' } },
	on_attach = function(client, bufnr)
		vim.api.nvim_buf_create_user_command(bufnr, 'LspCopilotSignIn', function()
			client:request('signIn', vim.empty_dict(), function(err, result)
				if err then vim.notify(err.message, vim.log.levels.ERROR); return end
				if result.command then
					vim.fn.setreg('+', result.userCode)
					local ok = vim.fn.confirm('Code copied. Open browser to sign in?', '&Yes\n&No')
					if ok == 1 then
						client:exec_cmd(result.command, { bufnr = bufnr }, function(e, r)
							if e then vim.notify(e.message, vim.log.levels.ERROR); return end
							if r.status == 'OK' then vim.notify('Signed in as ' .. r.user) end
						end)
					end
				elseif result.status == 'AlreadySignedIn' then
					vim.notify('Already signed in as ' .. result.user)
				end
			end)
		end, { desc = 'Copilot: sign in' })
		vim.api.nvim_buf_create_user_command(bufnr, 'LspCopilotSignOut', function()
			client:request('signOut', vim.empty_dict(), function(err)
				if err then vim.notify(err.message, vim.log.levels.ERROR) end
			end)
		end, { desc = 'Copilot: sign out' })
	end,
}
