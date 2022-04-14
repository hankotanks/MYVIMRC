" Vim with some enhancements
source $VIMRUNTIME/defaults.vim

" Shortcut to quickly open THIS FILE
nnoremap <leader>v :find $MYVIMRC<CR>

" Some very general options
set nu
set autochdir
set encoding=utf-8
set confirm
set fileencoding=utf-8
set nobackup
set ruler showmatch showmode
set backspace=indent,eol,start
set ignorecase
set incsearch smartcase

" Tabwidth options
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

" Linebreak options, softword wrap with two leading spaces
set wrap linebreak showbreak=\ \  nolist

" Soft wrap text when greater than 80 characters
set columns=80
autocmd VimResized * if (&columns > 80) | set columns=80 | endif

" Settings for gVim only
if has("gui_running")
  set guifont=Monospace:h13:cANSI
endif

" The following block is for plugins
set shellslash
set rtp+=~/vimfiles/bundle/Vundle.vim
call vundle#begin('~/vimfiles/bundle')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'YorickPeterse/vim-paper'
Plugin 'tpope/vim-unimpaired'

call vundle#end()
filetype plugin indent on " End of package manager stuff

" Theme configuration
if has('termguicolors')
  set termguicolors
endif
color paper

"
" ZETTEL RELATED CONFIGURATION
"

" Root dir for zettel system
let $M_DIR = '~/OneDrive/Slips/' 

" NAVIGATION OPTIONS
" Chord for opening the zettel index
nnoremap <leader>mm :e $M_DIR/Index.txt<CR>cd $M_DIR
" Faster shortcut for stepping back through buffers
nnoremap <BS> :bdelete<CR> 
" Quickly tab through xref links
nnoremap <TAB> /<</e<CR>w
" Go through links in reverse order
nnoremap <s-TAB> /<</e<CR>NNw
"Navigate to linked file
noremap <CR> :e <cfile><cr>

" SEARCH KEYS & HELPERS
" Perform a search in current directory
command! -nargs=1 Mgrep vimgrep "<args>" * 
nnoremap <leader>mf :Mgrep 
" Copy filename of current file and paste w/ adoc formatting
nnoremap <leader>mc :let @*=expand("%:t") <CR> 
nnoremap <leader>mp a<<<C-R>*>>

" ZETTEL CREATION
" Open buffer with new zettel
nnoremap <leader>mn :exe "edit %:h/" . strftime("%Y%m%d.%H%M") . ".txt" <CR>
" Insert link to new zettel at cursor position
nnoremap <leader>mnn :exe "normal! a" . "<<" . strftime("%Y%m%d.%H%M") . ".txt>>" <ESC> 3ge

" Update register.txt
nnoremap <leader>mu :! ruby reg.rb <CR>
" Update register.txt then orphans.txt
nnoremap <leader>muu :! ruby reg.rb & ruby orph.rb <CR>

"
"
"

" Use the internal diff if available. Otherwise use the special 'diffexpr' for Windows.
if &diffopt !~# 'internal'
  set diffexpr=MyDiff()
endif
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg1 = substitute(arg1, '!', '\!', 'g')
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg2 = substitute(arg2, '!', '\!', 'g')
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let arg3 = substitute(arg3, '!', '\!', 'g')
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      if empty(&shellxquote)
        let l:shxq_sav = ''
        set shellxquote&
      endif
      let cmd = '"' . $VIMRUNTIME . '\diff"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  let cmd = substitute(cmd, '!', '\!', 'g')
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
  if exists('l:shxq_sav')
    let &shellxquote=l:shxq_sav
  endif
endfunction
