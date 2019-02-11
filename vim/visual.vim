" colorize for syntax
syntax on

" 全角スペースの表示
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=reverse ctermfg=DarkGray gui=reverse guifg=DarkGray
endfunction

if has('syntax')
    augroup ZenkakuSpace
    autocmd!
    "ZenkakuSpace をカラーファイルで設定するなら、次の行をコメントアウト
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
