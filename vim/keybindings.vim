" create brackets pair
inoremap { {}<Left>
inoremap [ []<Left>
inoremap ( ()<Left>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap [<Enter> []<Left><CR><ESC><S-o>
inoremap (<Enter> ()<Left><CR><ESC><S-o>

" create apostrophe pair
inoremap ' ''<Left>
inoremap " ""<Left>

" create new tab
nnoremap <C-t> :tabnew<CR>
" clipboard integration
noremap <C-p> :r !pbpaste<CR>
