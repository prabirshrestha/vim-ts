let s:save_cpo = &cpo
set cpo&vim

function! ts#buffer#getCurrentBufferDir()
    return expand('%:p:h')
endfunction

function! ts#buffer#getCurrentBufferFilename()
    return expand('%:p')
endfunction

function! ts#buffer#getCurrentBufferLine()
    return line('.')
endfunction

function! ts#buffer#getCurrentBufferCol()
    return col('.')
endfunction

function! ts#buffer#getCurrentBufferContents()
    return getline(1, '$')
endfunction

function! ts#buffer#writeCurrentBufferToTempFile()
    let l:tempname = ts#utils#tempname()
    call ts#utils#writefile(ts#buffer#getCurrentBufferContents(), l:tempname)
    return l:tempname
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim sw=4 ts=4 et
