let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_neocomplete_php')
  finish
endif
let g:loaded_neocomplete_php = 1

if !exists('g:neocomplete_php_directory')
    let g:neocomplete_php_directory = $HOME.'/.neocomplete-php'
endif

let g:neocomplete_php_locale = get(g:, 'neocomplete_php_locale', 'en')
let g:neocomplete_php_dict = {
  \ 'internal_functions' : []
  \ }

command! -nargs=? PhpMakeDict call neocomplete#sources#php#helper#make_dict(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
