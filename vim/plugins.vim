"============ Dein Setting ============
if &compatible
  set nocompatible
endif
" setup dein in ~/.vim/dein directory
set runtimepath+=$HOME/.vim/dein/repos/github.com/Shougo/dein.vim

" add pyenv python3
let $PATH = "$HOME/.anyenv/envs/pyenv/shims:".$PATH

if dein#load_state('$HOME/.vim/dein')
  call dein#begin('$HOME/.vim/dein')
  call dein#add('$HOME/.vim/dein/repos/github.com/Shougo/dein.vim')

  call dein#add('vim-airline/vim-airline')
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/denite.nvim')
  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  end
  
  "call dein#add('Shougo/neosnippet.vim')
  "call dein#add('Shougo/neosnippet-snippets')
  "call dein#add('Shougo/vimfiler.vim') " vimfiler requires unite
  "call dein#add('Shougo/vimproc.vim', {'build' : 'make'})
  "call dein#add('Shougo/neossh.vim')
  "call dein#add('terryma/vim-multiple-cursors')
  "call dein#add('fatih/vim-go')
  "call dein#add('kannokanno/previm') " markdown preview
  "call dein#add('Shougo/vimshell', { 'rev': '3787e5' })

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
    call dein#install()
endif

"============ vim-airline setting =============
let g:airline#extensions#tabline#enabled = 1

"============ deoplete setting =============
let g:deoplete#enable_at_startup = 1

"============ lsp-go setting ============

if executable('go-langserver')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'go-langserver',
        \ 'cmd': {server_info->['go-langserver', '-gocodecompletion']},
        \ 'whitelist': ['go'],
        \ })
    autocmd BufWritePre *.go LspDocumentFormatSync
endif

"============ VimFiler Setting ============
"" automatic startup
""autocmd VimEnter * VimFilerBufferDir -split -simple -winwidth=25 -no-quit
"" vimfiler will be used as the default explorer
"let g:vimfiler_as_default_explorer=1
"nnoremap <C-f> :VimFilerBufferDir -split -simple -winwidth=20 -no-quit<CR>
"inoremap <C-f> <ESC>:VimFilerBufferDir -split -simple -winwidth=20 -no-quit<CR>
"
""============ previm Setting ============
""ブラウザの設定"
"let g:previm_open_cmd = 'open -a Google\ Chrome'
"augroup PrevimSettings
"    autocmd!
"    autocmd BufNewFile,BufRead *.{md,mdown,mark*} set filetype=markdown
"augroup END
