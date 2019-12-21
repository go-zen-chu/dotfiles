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
" enable mouse for insert mode
set mouse=i