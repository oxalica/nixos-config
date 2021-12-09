local opt = vim.o
local function map(mode, lhs, rhs, opts)
  vim.api.nvim_set_keymap(mode, lhs, rhs, opts or {})
end

-- Basic settings. {{{1

-- Core.
opt.fileencodings = 'ucs-bom,utf-8,gb18030,latin1'
opt.foldmethod = 'marker'
opt.lazyredraw = true
opt.mouse = 'a'
opt.scrolloff = 5
opt.undofile = true

-- No undo for tmp files
vim.cmd('autocmd BufWritePre /tmp/*,/var/tmp/*,/dev/shm/* setlocal noundofile nobackup')

-- Input.
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.ttimeoutlen = 1

-- Render.
opt.number = true
opt.cursorline = true
opt.signcolumn = 'yes' -- Always show.
opt.list = true
opt.listchars = 'tab:-->,extends:>,precedes:<'

-- Reference: https://github.com/lilydjwg/dotvim/blob/07c4467153f2f44264fdb0e23c085b56cad519db/vimrc#L548
-- <path/to/file [+][preview][RO][filetype][binary][encoding][BOM][dos][noeol]
--   === char code, line, column, byte position, percentage
opt.laststatus = 2 -- Always show.
opt.statusline =
  '%<%f %m%r%y' ..
  '%{&bin?"[binary]":""}' ..
  '%{!&bin&&&fenc!="utf-8"&&&fenc!=""?"[".&fenc."]":""}' ..
  '%{!&bin&&&bomb?"[BOM]":""}' ..
  '%{!&bin&&&ff!="unix"?"[".&ff."]":""}' ..
  '%{!&eol?"[noeol]":&bin?"[eol]":""}' ..
  ' %LL  %-8.{luaeval("require[[lsp-status]].status()")}' ..
  '%=' ..
  ' 0x%-4.B %-16.(%lL,%cC%V,%oB%) %P'

function get_lsp_status()
  return #vim.lsp.buf_get_clients() and require('lsp-status').status() or ''
end

-- Mapping. {{{1

vim.g.mapleader = '\\'

-- Fixup for consistency.
map('n', 'Y', 'y$')

-- Command-like.
map('n', '<m-z>', '<cmd>set wrap!<cr>')
map('i', '<m-z>', 'set wrap!', { expr = true })
map('n', '<cr>', '<cmd>set hlsearch! | set hlsearch?<cr>')

-- Panes
map('n', '<c-w>v', ':vsplit<cr>')
map('n', '<c-w>s', ':split<cr>')
map('n', '<c-w>+', '<c-w>+<c-w>+<c-w>+<c-w>+<c-w>+')
map('n', '<c-w>-', '<c-w>-<c-w>-<c-w>-<c-w>-<c-w>-')
map('n', '<c-w><', '<c-w><<c-w><<c-w><<c-w><<c-w><')
map('n', '<c-w>>', '<c-w>><c-w>><c-w>><c-w>><c-w>>')

vim.cmd('command -nargs=0 Sudow w !sudo tee % >/dev/null')
vim.cmd('command -nargs=* W w <args>')

-- vim: sw=2 et :
