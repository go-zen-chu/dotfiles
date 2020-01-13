" create brackets pair
inoremap { {}<Left>
inoremap [ []<Left>
inoremap ( ()<Left>
" create brackets with enter
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap [<Enter> []<Left><CR><ESC><S-o>
inoremap (<Enter> ()<Left><CR><ESC><S-o>
" create apostrophe pair
inoremap ' ''<Left>
inoremap " ""<Left>

" clipboard integration
noremap <C-p> :r !pbpaste<CR>

" manage window 
" split and open different file
noremap <C-w><bar> :vsplit<CR>:Files<CR>
noremap <C-w>- :split<CR>:Files<CR>
" make it resize larger
noremap <C-w>< :vertical resize -10<CR>
noremap <C-w>> :vertical resize +10<CR>

" toggle-terminal setting
noremap <C-t> :ToggleTerminal<CR>
" in terminal mode, need C-w for putting command
tnoremap <C-t> <C-w>:ToggleTerminal<CR>
