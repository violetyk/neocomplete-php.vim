let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_neocomplete_php')
  finish
endif
let g:loaded_neocomplete_php = 1

let g:neocomplete_php_locale = get(g:, 'neocomplete_php_locale', 'ja')
let g:neocomplete_php_dict = {
  \ 'internal_functions' : []
  \ }

command! PhpMakeDictJa call neocomplete#sources#php#helper#make_dict('ja')
command! PhpMakeDictEn call neocomplete#sources#php#helper#make_dict('en')

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
