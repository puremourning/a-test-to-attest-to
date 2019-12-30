"*******************************************************************************
" Standard boilerplate {{{
"*******************************************************************************
if exists( "g:loaded_attest" )
  finish
endif

if !has( 'timers' )
  finish
endif

let s:save_cpo = &cpo
set cpo&vim
" }}}

"*******************************************************************************
" Actual completion logic {{{
"*******************************************************************************

" The code is taken directly from the example in the Vim documentation
function! s:FindStart() abort
  " locate the start of the word
  let line = getline('.')
  let start = col('.') - 1
  while start > 0 && line[start - 1] =~ '\a'
    let start -= 1
  endwhile
  return start
endfunction

" The code is taken directly from the example in the Vim documentation
function! s:CompleteMonth( base ) abort
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
function! attest#CompleteSimple( findstart, base ) abort
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

function s:KillTimer() abort
  call timer_stop( s:complete_timer )
  let s:complete_timer = -1
  augroup ATestClear
    au!
  augroup END
endfunction

function! s:DoAsyncCompletion( start_col, base, id ) abort
  call complete( a:start_col, s:CompleteMonth( a:base ) )
endfunction

" See :help complete-functions
function! attest#CompleteAsync( findstart, base ) abort
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

  " Do something complicated that takes time. Pass the current column (actually
  " the start column) and the 'query' (a:base) to the callback using a partial.
  let s:complete_timer =  timer_start( 200,
                                     \ function( "s:DoAsyncCompletion",
                                               \ [ col( '.' ), a:base ] ) )

  return v:none
endfunction

" }}}

"*******************************************************************************
" Standard boilerplate {{{
"*******************************************************************************
let &cpo = s:save_cpo
" }}}

" Vim: foldmethod=marker
