" vim-plug
call plug#begin('$HOME/.vim/plugged')

" install plugins
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'junegunn/fzf.vim'

call plug#end()

" lightline setting 
" not show which mode (substituted by lightline)
set noshowmode

" vim-fzf setting
" set path to fzf from vim
set rtp+=/usr/local/opt/fzf
" overwrite Files command so that it could search hidden files
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, {'source':'find . -type f -not -path "*/\.git/*" -not -name "*.swp"'}, <bang>0)
