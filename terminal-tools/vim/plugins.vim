" vim-plug
call plug#begin('$HOME/.vim/plugged')

" install plugins
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
" coc is not used on termux
if empty($TERMUX_VERSION)
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
Plug 'junegunn/fzf.vim'

call plug#end()

" lightline setting 
" not show which mode (substituted by lightline)
set noshowmode

" coc setting
if empty($TERMUX_VERSION)
  call coc#add_extension('coc-json', 'coc-css', 'coc-markdownlint')
endif

" vim-fzf setting
" set path to fzf from vim
set rtp+=/usr/local/opt/fzf
" overwrite Files command so that it could search hidden files
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, {'source':'find . -type f -not -path "*/\.git/*" -not -name "*.swp"'}, <bang>0)
