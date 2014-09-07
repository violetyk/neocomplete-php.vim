let s:save_cpo = &cpo
set cpo&vim

let s:V       = vital#of('neocomplete_php')
let s:Message = s:V.import('Vim.Message')
let s:File    = s:V.import('System.File')
let s:Cache   = s:V.import('System.Cache')
let s:Process = s:V.import('Process')
let s:XML     = s:V.import('Web.XML')
let s:String  = s:V.import('Data.String')

let s:work_dir   = g:neocomplete_php_directory . '/'
let s:phpdoc_dir = s:work_dir . 'phpdoc/'
let s:cache_dir  = s:work_dir . 'cache/'
let s:debug_log  = '/var/tmp/neocomplete-php.log'

function! neocomplete#sources#php#helper#make_dict(...)

  if a:0 == 0
    let locale = g:neocomplete_php_locale
  else
    let locale = a:1
  endif

  call neocomplete#sources#php#helper#prepare_php_manual(locale)

  let function_list = neocomplete#sources#php#helper#get_internal_function_list()
  let phpdoc_reference_dir = neocomplete#sources#php#helper#dir_phpdoc_reference(locale)

  " internal functions
  let internal_functions = []
  for f in function_list
    let path = findfile(substitute(f, '_', '-', 'g') . '.xml', phpdoc_reference_dir . '**5')
    if strlen(path)
      try
        let xml = s:XML.parseFile(path)
        let refpurpose = xml.find('refpurpose').value()
        let refpurpose = substitute(refpurpose, '\r\n\|[\r\n]', '', 'g')
        let refpurpose = s:String.trim(refpurpose)

        call add(internal_functions, {
              \ 'word' : f,
              \ 'abbr' : f . '()',
              \ 'menu' : refpurpose,
              \ 'kind' : '[f]'
              \ })

        redraw!
        echo f . ' ' . refpurpose
      catch
        call s:Message.error('make error.')
        return
      endtry
    endif
  endfor

  " set
  let g:neocomplete_php_dict.internal_functions = internal_functions

  " cache
  call s:File.mkdir_nothrow(s:cache_dir, 'p')
  call s:Cache.writefile(s:cache_dir, locale, [string(internal_functions)])

  redraw!
  echo 'finish.'

endfunction

function! neocomplete#sources#php#helper#load_candidate_cache(locale) "{{{
  try
    let g:neocomplete_php_dict.internal_functions = eval(get(s:Cache.readfile(s:cache_dir, a:locale), 0, '[]'))
  catch
    call s:Cache.deletefile(s:cache_dir, a:locale)
  endtry
endfunction "}}}
function! neocomplete#sources#php#helper#has_candidate_cache(locale) "{{{
  return filereadable(s:cache_dir . a:locale)
endfunction "}}}
function! neocomplete#sources#php#helper#dir_phpdoc(locale) "{{{
  return s:phpdoc_dir . a:locale . '/'
endfunction "}}}
function! neocomplete#sources#php#helper#dir_phpdoc_reference(locale) "{{{
  return s:phpdoc_dir . a:locale . '/reference/'
endfunction "}}}
function! neocomplete#sources#php#helper#prepare_php_manual(locale) "{{{
  if !executable('svn')
    call s:Message.error('svn is required.')
    return 0
  endif

  call s:File.mkdir_nothrow(s:phpdoc_dir, 'p')

  let locale_phpdoc_dir = neocomplete#sources#php#helper#dir_phpdoc(a:locale)
  if isdirectory(locale_phpdoc_dir . '/.svn')
    let cmd = printf('!svn update -q https://svn.php.net/repository/phpdoc/%s/trunk %s',
          \ a:locale,
          \ locale_phpdoc_dir
          \ )
  else
    let cmd = printf('!svn co -q https://svn.php.net/repository/phpdoc/%s/trunk %s',
          \ a:locale,
          \ locale_phpdoc_dir
          \ )
  endif

  echo 'now getting a new php manual, please wait.'
  sleep 2
  execute cmd
  return v:shell_error != 0

endfunction "}}}
function! neocomplete#sources#php#helper#get_internal_function_list() " {{{
  if !executable('php')
    call s:Message.error('php is required.')
    return
  endif

  let function_list = []

  try
    let code  = '$functions = get_defined_functions();'
    let code .= 'echo json_encode($functions["internal"]);'
    let cmd = 'php -r ''' . code . ''''
    let function_list = eval(system(cmd))
  catch
  endtry

  return function_list

endfunction " }}}

function! neocomplete#sources#php#helper#on_complete_done() "{{{

  if &filetype != 'php'
    return
  endif

  let complete_str =
        \ neocomplete#helper#match_word(
        \   matchstr(getline('.'), '^.*\%'.col('.').'c'))[1]

  let neocomplete = neocomplete#get_current_neocomplete()
  let candidates = filter(copy(neocomplete.candidates),
        \   "v:val.word ==# complete_str &&
        \    (get(v:val, 'abbr', '') != '' &&
        \     v:val.word !=# v:val.abbr && v:val.abbr[-1] != '~') ||
        \     get(v:val, 'info', '') != ''")
  if !empty(candidates)
    let completed_item = candidates[0]

    let cmd = 'php --rf ' . completed_item.word
    let option = {
          \ 'use_vimproc': 1
          \ }
    let r = s:Process.system(cmd, option)
    echo r

    " echo candidates
    " let _tmp = &statusline
    " let &statusline = 'hogehogehgoehgoege'
    " let &statusline = _tmp
  endif


endfunction "}}}

function! neocomplete#sources#php#helper#debug(...) " {{{
  execute ":redir! >> " . s:debug_log
  silent echon localtime() . ' ' . string(a:000) . "\n"
  :redir END
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
