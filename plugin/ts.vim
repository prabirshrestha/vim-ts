let s:save_cpo = &cpo
set cpo&vim

function! s:restore_cpo()
    let &cpo = s:save_cpo
    unlet s:save_cpo
endfunction

if exists('g:loaded_vim_ts_plugin')
    call s:restore_cpo()
    finish
elseif !(has('job'))
    echohl WarningMsg
    echomsg 'vim-ts requires vim with job'
    echohl None
    call s:restore_cpo()
    finish
endif

let g:loaded_vim_ts_plugin = 1

call s:restore_cpo()

" vim sw=4 ts=4 et
