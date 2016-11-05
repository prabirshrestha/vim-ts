let s:save_cpo = &cpo
set cpo&vim

function! ts#utils#tempname()
    return tempname()
endfunction

function! ts#utils#writefile(contents, filename)
    call writefile(a:contents, a:filename)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim sw=4 ts=4 et
