"*******************************************************************************
" Standard boilerplate {{{
"*******************************************************************************
if exists( "g:loaded_atest" )
  finish
endif

if !has( 'timers' )
  finish
endif

let save_cpo = &cpo
" }}}

"*******************************************************************************
" Actual completion logic {{{
"*******************************************************************************

" The code is taken directly from the example in the Vim documentation
function! s:FindStart()
  " locate the start of the word
  let line = getline('.')
  let start = col('.') - 1
  while start > 0 && line[start - 1] =~ '\a'
    let start -= 1
  endwhile
  return start
endfunction

" The code is taken directly from the example in the Vim documentation
function! s:CompleteMonth( base )
  " find months matching with "a:base"
  let res = []
  for m in split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec")
    if m =~ '^' . a:base
      call add(res, m)
    endif
  endfor
  return res
endfunction

" }}}

"*******************************************************************************
" Simple completion {{{
"*******************************************************************************

  " See :help complete-functions
  function! atest#CompleteSimple( findstart, base ) abort
    if a:findstart
      return s:FindStart()
    else
      return s:CompleteMonth( a:base )
    endif
  endfunction

" }}}

"*******************************************************************************
" Async completion {{{
"*******************************************************************************

let s:complete_timer = -1
let s:complete_base = v:none

function s:KillTimer() abort
  call timer_stop( s:complete_timer )
  let s:complete_timer = -1
  augroup ATestClear
    au!
  augroup END
endfunction

function! s:DoAsyncCompletion( id ) abort
  call complete( s:FindStart() + 1, s:CompleteMonth( s:complete_base ) )
endfunction

" See :help complete-functions
function! atest#CompleteAsync( findstart, base ) abort
  if a:findstart
    " We will work out the start position later
    return s:FindStart()
  endif

  " Kill any existing request
  call s:KillTimer()

  " Kill the timer when leaving insert mode
  augroup ATestClear
    au InsertLeave * ++once call <SID>KillTimer()
  augroup END

  " Do something complicated that takes time.
  let s:complete_base = a:base
  let s:complete_timer =  timer_start( 200, function( "s:DoAsyncCompletion" ) )

  return v:none
endfunction

" }}}

"*******************************************************************************
" Standard boilerplate {{{
"*******************************************************************************
let &cpo = save_cpo
" }}}

" Vim: foldmethod=marker
