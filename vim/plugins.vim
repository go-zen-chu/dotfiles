" vim-plug
call plug#begin('$HOME/.vim/plugged')

" install plugins
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf.vim'

call plug#end()

" lightline setting 
" not show which mode (substituted by lightline)
set noshowmode

" coc setting
call coc#add_extension('coc-json', 'coc-css')

" vim-fzf setting
" set path to fzf from vim
set rtp+=/usr/local/opt/fzf


