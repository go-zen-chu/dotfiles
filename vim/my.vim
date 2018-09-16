" vimに必要なもの
" * dein
" * molokai colorscheme(編集したものがbitbucketにある。my_monokai)

" Dein Setting
    if &compatible
        set nocompatible                 " Be iMproved
    endif

    " Required:
    set runtimepath^=$HOME/.vim/dein/repos/github.com/Shougo/dein.vim

    " Required:
    call dein#begin(expand('$HOME/.vim/dein'))
    " Let dein manage dein
    " Required:
    call dein#add('Shougo/dein.vim')

    " Add or remove your plugins here:
    call dein#add('vim-airline/vim-airline') " this should be come before neocomplete for key bind
    call dein#add('Shougo/neocomplete.vim') " neocomplete requires lua
    call dein#add('Shougo/neosnippet.vim')
    call dein#add('Shougo/neosnippet-snippets')
    call dein#add('Shougo/unite.vim')
    call dein#add('Shougo/vimfiler.vim') " vimfiler requires unite
    call dein#add('Shougo/vimproc.vim', {'build' : 'make'})
    call dein#add('Shougo/neossh.vim')
    call dein#add('terryma/vim-multiple-cursors')
    "call dein#add('kannokanno/previm') " markdown preview
    "call dein#add('fatih/vim-go')

    " You can specify revision/branch/tag.
    " vimshell も便利そうだが、zshで代替できる
    " call dein#add('Shougo/vimshell', { 'rev': '3787e5' })

    " Required:
    call dein#end()
    " Required:
    filetype plugin indent on
    " If you want to install not installed plugins on startup.
    if dein#check_install()
        call dein#install()
    endif

" VimFiler Setting
    " automatic startup
    "autocmd VimEnter * VimFilerBufferDir -split -simple -winwidth=25 -no-quit
    " vimfiler will be used as the default explorer
    let g:vimfiler_as_default_explorer=1
    nnoremap <C-f> :VimFilerBufferDir -split -simple -winwidth=20 -no-quit<CR>
    inoremap <C-f> <ESC>:VimFilerBufferDir -split -simple -winwidth=20 -no-quit<CR>

" neocomplete Setting
    " https://github.com/Shougo/neocomplete.vi://github.com/Shougo/neocomplete.vim
    " Disable AutoComplPop.
    let g:acp_enableAtStartup = 0
    " Use neocomplete.
    let g:neocomplete#enable_at_startup = 1
    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_keyword_length = 3
    " Define dictionary.
    let g:neocomplete#sources#dictionary#dictionaries = {
        \ 'default' : ''
        \ }

    " Define keyword.
    if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'
    " Plugin key-mappings.
    "inoremap <expr><C-g>     neocomplete#undo_completion()
    inoremap <expr><C-l>     neocomplete#complete_common_string()

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
      return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
      " For no inserting <CR> key.
      "return pumvisible() ? "\<C-y>" : "\<CR>"
    endfunction
    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    " Close popup by <Space>.
    "inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"
    " Enable omni completion.
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType go set omnifunc=gocomplete#Complete

    " Enable heavy omni completion.
    if !exists('g:neocomplete#sources#omni#input_patterns')
      let g:neocomplete#sources#omni#input_patterns = {}
    endif
    "let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
    "let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
    "let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
    let g:neocomplete#sources#omni#input_patterns.javascript = '[^. \t]\.\%(\h\w*\)\?'
    let g:neocomplete#sources#omni#input_patterns.python = '[^. *\t]\.\w*\|\h\w*'
    let g:neocomplete#sources#omni#input_patterns.go = '\h\w\.\w*'

" neosnippet Setting
    " Plugin key-mappings. map を実行することで、<Plug>(neosnippet_expand_target) が評価される
    imap <C-k>     <Plug>(neosnippet_expand_or_jump)
    "smap <C-k>     <Plug>(neosnippet_expand_or_jump)
    "xmap <C-k>     <Plug>(neosnippet_expand_target)

    " SuperTab like snippets behavior.
    "imap <expr><TAB>
    " \ pumvisible() ? "\<C-n>" :
    " \ neosnippet#expandable_or_jumpable() ?
    " \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
    "smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
    "\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" previm Setting
    "ブラウザの設定"
    let g:previm_open_cmd = 'open -a Google\ Chrome'
    augroup PrevimSettings
        autocmd!
        autocmd BufNewFile,BufRead *.{md,mdown,mark*} set filetype=markdown
    augroup END

" Standard Vim Setting
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
    " 改行をまたいで矢印移動
    set whichwrap=b,s,<,>,[,]
    " 折りたたみの設定
    set foldmethod=indent
    " 初期値で開いたままにするための施策
    " http://vim.wikia.com/wiki/All_folds_open_when_opening_a_file
    set foldlevelstart=20
    " cmd + v でvisual選択したものをクリップボードに移せる(* vimのバージョン依存)
    " http://qiita.com/HelloPeople/items/3ca4ab80fc465d8eed7e
    "set clipboard=unnamed
    " バックスペースで改行を消せるようにする
    set backspace=2
    " インクリメンタルサーチ（文字を打ちながら検索できる機能）をオンにする
    set incsearch
    " サーチなどでcase sensitiveじゃなくする方法
    set ignorecase
    " サーチでカーソルを見失ってしまうので
    set cursorline
    " マウスでの移動をinsertのみ許可（これにより、normal時にはcopy and pasteができる）
    set mouse=i
    " インデントの表示を明示的にする
    set list
    set listchars=tab:>\

" Key mapping Setting
    " 閉じかっこを自動で作る
    " inoremap { {}<Left>
    inoremap {<Enter> {}<Left><CR><ESC><S-o>
    "inoremap [ []<Left>
    inoremap [<Enter> []<Left><CR><ESC><S-o>
    "inoremap ( ()<Left>
    inoremap (<Enter> ()<Left><CR><ESC><S-o>
    "" アポストロフィの補完
    "inoremap ' ''<Left>
    "inoremap " ""<Left>

    " タブの作成
    nnoremap <C-t> :tabnew<CR>
    " clipboard integration
    noremap <C-p> :r !pbpaste<CR>
    " (may be for *nix) make sure backspace do function with ctrl+H
    "noremap ^? ^H
    "noremap! ^? ^H
    "noremap ^H
    "noremap! ^H

" Syntax & Color Scheme Setting
    " colorize for syntax
    syntax on
    " 全角スペースの表示
    function! ZenkakuSpace()
        highlight ZenkakuSpace cterm=reverse ctermfg=DarkGray gui=reverse guifg=DarkGray
    endfunction

    if has('syntax')
        augroup ZenkakuSpace
        autocmd!
        "ZenkakuSpace をカラーファイルで設定するなら、
        "次の行をコメントアウト
        autocmd ColorScheme       * call ZenkakuSpace()
        autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
        augroup END
        call ZenkakuSpace()
    endif

    " .vim/colors にインストールしたmy_monokaiスキームを適用する
    " Error 'Cannot find color scheme' will be caused if you set colorscheme
    " before dein setting and 'syntax on'
    colorscheme my_monokai
    set t_Co=256
