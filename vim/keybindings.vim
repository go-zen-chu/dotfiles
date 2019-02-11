"inoremap { {}<Left> " 閉じかっこを自動で作る
"inoremap [ []<Left>
"inoremap ( ()<Left>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap [<Enter> []<Left><CR><ESC><S-o>
inoremap (<Enter> ()<Left><CR><ESC><S-o>

" アポストロフィの補完
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
