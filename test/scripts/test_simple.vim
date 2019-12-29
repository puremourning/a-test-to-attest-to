let g:test_name = expand( "<sfile>:p:t" )
let g:test_path = expand( "<sfile>:p:h" )
let init_script = expand( '<sfile>:p:h' ) . '/../support/' . test_name
execute 'source ' . init_script

function! s:EarlyExit()
  call add( v:errors, "Test caused Vim to quit!" )
  call s:Done()
endfunction

function! s:Done()
  if len( v:errors ) > 0
    " Append errors to test failure log
    let logfile = g:test_path . "/" . g:test_name . ".failed.log"
    call writefile( v:errors, logfile, 'as' )

    " Quit with an error code
    cquit!
  else
    quit!
  endif
endfunction

" * Type `i<C-x><C-u>`. Expect the buffer to contain `Jan`

let v:errors = []
au VimLeavePre * call s:EarlyExit()
try
  call feedkeys( "i\<C-x>\<C-u>", 'xt' )
  call assert_equal( 'Jan', getline( 1 ) )
catch
  call add( v:errors,
        \   "Uncaught exception in test: "
        \ . v:exception
        \ . " at "
        \ . v:throwpoint )
finally
  au! VimLeavePre
endtry

call s:Done()
