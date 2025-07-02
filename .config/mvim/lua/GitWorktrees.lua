local wt_switch = function(item)
  -- NOTE: Change CWD to selected item's path
  vim.schedule(function()
    vim.fn.chdir(item.path)
  end)
  vim.notify(
    'Git worktree changed to ' .. (item.branch and item.branch or '(bare)'),
    vim.log.levels.INFO
  )
end

--- @return { text: string, branch: string, path: string }[]
local wt_postprocess = function(item)
  local items = {}
  for _, entry in pairs(vim.split(item[1], '%z%z', { trimempty = true })) do
    local path, head, _, ref =
    entry:match('^worktree (.-)%zHEAD (.-)%z([^ ]+) (.+)$')
    if path then
      local branch = vim.fs.basename(ref)
      items[#items + 1] = {
        text = string.format(
          '[%s] %s %s',
          branch,
          head:sub(1, 7),
          path
        ),
        branch = branch,
        path = path,
      }
    else
      path = entry:match('^worktree (.-)%z(bare)$')
      if path then
        items[#items + 1] = {
          text = string.format('(bare) %s', path),
          branch = nil,
          path = path,
        }
      end
    end
  end
  return items
end

MiniPick.registry.git_worktrees = function(local_opts)
  local cwd = local_opts.cwd or vim.fn.getcwd()
  if vim.system({ 'git', '-C', cwd, 'rev-parse' }):wait().code ~= 0 then
    vim.notify(
      'Not in a git repository',
      vim.log.levels.ERROR
    )
    return
  end
  local opts = {
    source = {
      -- NOTE: Window Title
      name = string.format('Git Worktrees - %s', cwd),
      choose = wt_switch,
    },
  }
  local_opts.command =
  { 'git', '-C', cwd, 'worktree', 'list', '--porcelain', '-z' }
  local_opts.postprocess = wt_postprocess

  return MiniPick.builtin.cli(local_opts, opts)
end

