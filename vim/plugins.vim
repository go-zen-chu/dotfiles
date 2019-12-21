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
  call dein#add('fatih/vim-go')
  call dein#add('junegunn/fzf.vim')

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

"============ vim-go setting ============
" using gopls as language server
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
" for debug
"let g:go_debug = ['lsp']
"let g:go_gocode_socket_type = 'tcp'

"============ vim-fzf setting ===========
" set path to fzf from vim
set rtp+=/usr/local/opt/fzf

