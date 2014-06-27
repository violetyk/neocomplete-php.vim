let s:save_cpo = &cpo
set cpo&vim

let s:V       = vital#of('neocomplete-php')
let s:Message = s:V.import('Vim.Message')
let s:File    = s:V.import('System.File')
let s:Cache   = s:V.import('System.Cache')
let s:Process = s:V.import('Process')
let s:XML     = s:V.import('Web.XML')
let s:String  = s:V.import('Data.String')

let s:work_dir = g:neocomplete_php_directory . '/'
let s:phpdoc_dir = s:work_dir . 'phpdoc/'
let s:cache_dir = s:work_dir . 'cache/'

let s:debug_log = '/var/tmp/neocomplete-php.log'

function! neocomplete#sources#php#helper#make_dict(...)

  if a:0 == 0
    let l:locale = g:neocomplete_php_locale
  else
    let l:locale = a:1
  endif

  call neocomplete#sources#php#helper#prepare_php_manual(l:locale)

  let l:function_list = neocomplete#sources#php#helper#get_internal_function_list()
  let l:phpdoc_reference_dir = neocomplete#sources#php#helper#dir_phpdoc_reference(l:locale)

  " internal functions
  let l:internal_functions = []
  for l:f in l:function_list
    let l:path = findfile(substitute(l:f, '_', '-', 'g') . '.xml', l:phpdoc_reference_dir . '**5')
    if strlen(l:path)
      try
        let l:xml = s:XML.parseFile(l:path)
        let l:refpurpose = l:xml.find('refpurpose').value()
        let l:refpurpose = substitute(l:refpurpose, '\r\n\|[\r\n]', '', 'g')
        let l:refpurpose = s:String.trim(l:refpurpose)

        call add(l:internal_functions, {
              \ 'word' : l:f,
              \ 'abbr' : l:f . '()',
              \ 'menu' : l:refpurpose,
              \ 'kind' : '[f]'
              \ })

        redraw!
        echo l:f . ' ' . l:refpurpose
      catch
        call s:Message.error('make error.')
        return
      endtry
    endif
  endfor

  " set
  let g:neocomplete_php_dict.internal_functions = l:internal_functions

  " cache
  call s:File.mkdir_nothrow(s:cache_dir, 'p')
  call s:Cache.writefile(s:cache_dir, l:locale, [string(l:internal_functions)])

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

  let l:locale_phpdoc_dir = neocomplete#sources#php#helper#dir_phpdoc(a:locale)
  if isdirectory(l:locale_phpdoc_dir . '/.svn')
    let l:cmd = printf('!svn update -q https://svn.php.net/repository/phpdoc/%s/trunk %s',
          \ a:locale,
          \ l:locale_phpdoc_dir
          \ )
  else
    let l:cmd = printf('!svn co -q https://svn.php.net/repository/phpdoc/%s/trunk %s',
          \ a:locale,
          \ l:locale_phpdoc_dir
          \ )
  endif

  echo 'now getting a new php manual, please wait.'
  sleep 2
  execute l:cmd
  return v:shell_error != 0

endfunction "}}}
function! neocomplete#sources#php#helper#get_internal_function_list() " {{{
  if !executable('php')
    call s:Message.error('php is required.')
    return
  endif

  let l:function_list = []

  try
    let l:code  = '$functions = get_defined_functions();'
    let l:code .= 'echo json_encode($functions["internal"]);'
    let l:cmd = 'php -r ''' . l:code . ''''
    let l:function_list = eval(system(l:cmd))
  catch
  endtry

  return l:function_list

endfunction " }}}

function! neocomplete#sources#php#helper#debug(...) " {{{
  execute ":redir! >> " . s:debug_log
  silent echon localtime() . ' ' . string(a:000) . "\n"
  :redir END
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fenc=utf-8 ff=unix ft=vim fdm=marker:
