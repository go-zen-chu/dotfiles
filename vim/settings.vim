set encoding=utf-8
set fileencodings=utf-8

" tab is 4 space length
set tabstop=4
" indent length
set shiftwidth=4
" automatically indent
set smarttab
" convert \t to space
set expandtab
set autoindent
" set line number
set number
" move to prev, next line with cursor
set whichwrap=b,s,<,>,[,]
" indent setting
set foldmethod=indent
" open all indent when open
" http://vim.wikia.com/wiki/All_folds_open_when_opening_a_file
set foldlevelstart=20
" show indent
set list
set listchars=tab:>\

" add to clipboard when you selected in visual mode
" http://qiita.com/HelloPeople/items/3ca4ab80fc465d8eed7e
set clipboard+=unnamed
" you can remove char with backspace
set backspace=2
" enable incremental search
set incsearch
" case insensitive for search
set ignorecase
" set cursor line when searching
set cursorline
" enable mouse for all mode
set mouse=a

" no prompt when changing buffer
set hidden

" terminal setting
let s:toggle_term_rows = 10
function! ToggleTerminal() abort
    let buffer_num = bufnr('ToggleTerminal')
    if buffer_num == -1 || bufloaded(buffer_num) != 1
        " create terminal buffer
        let buffer_num = term_start($SHELL, {
          \ 'term_name':'ToggleTerminal',
          \ 'term_finish':'close',
          \ 'term_kill':'term'
          \ })
        if buffer_num == 0 
            echo "failed to open terminal"
            return
        endif
        " put terminal on very bottom
        execute 'wincmd J | resize '.s:toggle_term_rows
    else
        " manage terminal buffer if exists
        let window_num = bufwinnr(buffer_num)
        if window_num == -1
            " open buffered window
            execute 'sbuffer '.buffer_num.'| wincmd J | resize '.s:toggle_term_rows
        else
            " hide window
            execute window_num . 'wincmd w'
            hide 
        endif
    endif
endfunction
command! -nargs=0 ToggleTerminal call ToggleTerminal()

" netrw setting
" remove banner
let g:netrw_banner=0
" expand/shrink support for netrw 
let g:netrw_usetab=1
" tree style
let g:netrw_liststyle=3
" open in previous window 
let g:netrw_browse_split=4
" open netrw on left
let g:netrw_altv=1
" split vertically when preview
let g:netrw_preview=1
" width percent of netrw
let g:netrw_winsize=20
augroup ProjectDrawer
  autocmd!
  " open netrw when start vim then focus to editor
  autocmd VimEnter * :Lexplore | :wincmd l 
augroup END

