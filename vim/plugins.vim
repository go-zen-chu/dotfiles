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
call coc#add_extension('coc-json', 'coc-css', 'coc-markdownlint')

" vim-fzf setting
" set path to fzf from vim
set rtp+=/usr/local/opt/fzf
" overwrite Files command so that it could search hidden files
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, {'source':'find . -type f -not -path "*/\.git/*"'}, <bang>0)
