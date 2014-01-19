let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \ 'name'        : 'php',
      \ 'kind'        : 'manual',
      \ 'filetypes'   : {'php': 1, },
      \ 'mark'        : '[php]',
      \ 'is_volatile' : 1,
      \ 'rank'        : 100,
      \ 'hooks'       : {},
      \}
function! neocomplete#sources#php#define() "{{{
  return s:source
endfunction "}}}

let s:V       = vital#of('neocomplete-php')
let s:Message = s:V.import('Vim.Message')

function! s:source.gather_candidates(...) "{{{
  " call s:d(a:000)
  return deepcopy(g:neocomplete_php_dict.internal_functions)
endfunction " }}}

function! s:source.hooks.on_init(context) "{{{
  " call neocomplete#custom#source('buffer', 'disabled_filetypes', s:source.filetypes)
  " call neocomplete#custom#source('file', 'disabled_filetypes', s:source.filetypes)
  " call neocomplete#custom#source('file_include', 'disabled_filetypes', s:source.filetypes)
  " call neocomplete#custom#source('include', 'disabled_filetypes', s:source.filetypes)
  " call neocomplete#custom#source('member', 'disabled_filetypes', s:source.filetypes)
  " call neocomplete#custom#source('syntax', 'disabled_filetypes', s:source.filetypes)
  " call neocomplete#custom#source('tag', 'disabled_filetypes', s:source.filetypes)

  let l:locale = g:neocomplete_php_locale
  if neocomplete#sources#php#helper#has_candidate_cache(l:locale)
    call neocomplete#sources#php#helper#load_candidate_cache(l:locale)
  endif

  if empty(g:neocomplete_php_dict.internal_functions)
    call s:Message.warn('no dictionary. run command :PhpMakeDict ' . l:locale)
    sleep 3
    return
  endif

endfunction " }}}

function! s:d(...) "{{{
  call neocomplete#sources#php#helper#debug(a:000)
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
