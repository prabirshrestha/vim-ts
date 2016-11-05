let s:save_cpo = &cpo
set cpo&vim

let &cpo = s:save_cpo
unlet s:save_cpo

let s:default_tsClient = 0

function! ts#getDefaultClient()
    return s:default_tsClient
endfunction

function! ts#setDefaultClient(newClient)
    let s:default_tsClient = a:newClient
endfunction

function! ts#defaultClientExists()
    return type(ts#getDefaultClient()) == v:t_dict
endfunction

function! ts#defaultClientIsRunning()
    return ts#defaultClientExists() && ts#getDefaultClient().isRunning()
endfunction

function! ts#startServerIfNotRunning()
    if !ts#defaultClientIsRunning()
        call ts#setDefaultClient(ts#tssClient#new({}))
        call ts#getDefaultClient().start()
    endif
endfunction

function! ts#startServerIfNotRunningForFileBuffer()
    call ts#startServerIfNotRunning()
    call ts#getDefaultClient().flushCurrentBuffer()
endfunction

function! ts#stopServerIfRunning()
    if ts#defaultClientIsRunning()
        call ts#getDefaultClient().stop()
    endif
endfunction

function! ts#restartServer()
    call ts#stopServerIfRunning()
    call ts#startServerIfNotRunning()
endfunction

function! ts#definition()
    call ts#startServerIfNotRunning()
    call ts#getDefaultClient().definition()
endfunction

" vim sw=4 ts=4 et
