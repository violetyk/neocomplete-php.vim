if exists('g:loaded_neocomplete_php')
  finish
endif
let g:loaded_neocomplete_php = 1

let s:save_cpo = &cpo
set cpo&vim

let g:neocomplete_php_directory = get(g:, 'neocomplete_php_directory', $HOME . '/.neocomplete-php')
let g:neocomplete_php_locale    = get(g:, 'neocomplete_php_locale', 'en')
let g:neocomplete_php_dict      = {
  \ 'internal_functions' : []
  \ }

command! -nargs=? PhpMakeDict call neocomplete#sources#php#helper#make_dict(<f-args>)

augroup neocomplete-php
  autocmd!
  autocmd CompleteDone * call neocomplete#sources#php#helper#on_complete_done()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
