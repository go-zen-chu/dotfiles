" 文字化け対策
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
" 改行をまたいで矢印移動
set whichwrap=b,s,<,>,[,]
" 折りたたみの設定
set foldmethod=indent
" 初期値で開いたままにするための施策
" http://vim.wikia.com/wiki/All_folds_open_when_opening_a_file
set foldlevelstart=20
" cmd + v でvisual選択したものをクリップボードに移せる(* vimのバージョン依存)
" http://qiita.com/HelloPeople/items/3ca4ab80fc465d8eed7e
set clipboard+=unnamed
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
